# frozen_string_literal: true

module Obscured
  module AptWatcher
    module Controllers
      module Api
        module Collector
          class Upgrades < Obscured::AptWatcher::Controllers::Api::Base
            post '/:name' do |hostname|
              content_type :json

              hostname.gsub!(/[^a-zA-Z0-9\.\-_]/, '')
              begin
                host = Obscured::AptWatcher::Models::Host.where(hostname: hostname).first
                host = Obscured::AptWatcher::Models::Host.make!(hostname: hostname) if host.nil?

                request.body.rewind
                packages = []
                request.body.read.each_line do |package|
                  packages.push JSON.parse(package)
                end

                host.set_state(Obscured::State::CONNECTED)
                host.set_updates_pending(packages: packages)
                host.set_updates_installed(packages: packages)
                host.save!

                scan = Obscured::AptWatcher::Models::Scan.make!(hostname: hostname, packages: packages)
                attachments = [
                  {
                    color: scan.packages.count > 10 ? Obscured::Alert::Color::ERROR : Obscured::Alert::Color::WARN,
                    fallback: "There are #{packages.count} available updates for this host",
                    pretext: "There are #{packages.count} available updates for this host",
                    fields: [
                      {
                        title: 'Status',
                        value: 'Warning',
                        short: true
                      },
                      {
                        title: 'Host',
                        value: hostname,
                        short: true
                      },
                      {
                        title: 'Actions',
                        value: "<#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}/scan/#{scan.id}|Review in AptWatcher>"
                      }
                    ]
                  }
                ]

                # Only run matcher if host is older than one day
                unless host.created_at.today?
                  date_start = Date.yesterday.strftime('%Y-%m-%d')
                  date_end = Date.today.strftime('%Y-%m-%d')
                  Obscured::AptWatcher::Package::Matcher.run(hostname, date_start.to_s, date_end).to_json
                end

                alerts = Obscured::AptWatcher::Models::Alert.where(hostname: hostname, type: Obscured::Alert::Type::PACKAGES, status: Obscured::Status::OPEN).to_a
                if scan.packages.count.zero?
                  alerts = Obscured::AptWatcher::Models::Alert.where(hostname: hostname, type: Obscured::Alert::Type::PACKAGES, status: Obscured::Status::OPEN).to_a
                  alerts.each do |alert|
                    alert.status = Obscured::Status::CLOSED
                    alert.add_event(type: :status, message: "Changed status to #{alert.status}", producer: Obscured::Alert::Type::SYSTEM)
                    alert.save
                  end
                else
                  alerts.each do |alert|
                    alert.status = Obscured::Status::IGNORED
                    alert.add_event(type: :status, message: "Changed status to #{alert.status}", producer: Obscured::Alert::Type::SYSTEM)
                    alert.save
                  end

                  slack_client.post icon_emoji: scan.packages.count > 10 ? ':bug-error:' : ':bug-warn:', attachments: attachments if config.slack.enabled
                  Obscured::AptWatcher::Models::Alert.make!(hostname: hostname, type: Obscured::Alert::Type::PACKAGES, message: "There are #{scan.packages.count} available updates for this host", payload: attachments)
                end
                scan
              rescue => e
                host.set_state(Obscured::State::FAILING)

                attachments = [
                  {
                    color: Obscured::Alert::Color::ERROR,
                    fallback: e.message,
                    pretext: e.message,
                    fields: [
                      {
                        title: 'Status',
                        value: 'Error',
                        short: true
                      },
                      {
                        title: 'Host',
                        value: hostname,
                        short: true
                      },
                      {
                        title: 'Backtrace',
                        value: e.backtrace.join('\n')
                      }
                    ]
                  }
                ]
                slack_client.post icon_emoji: ':bug-error:', attachments: attachments if config.slack.enabled

                Obscured::AptWatcher::Models::Error.make!(notifier: Obscured::Alert::Type::SYSTEM, message: e.message, backtrace: e.backtrace.join('<br />'), payload: attachments)

                { success: false, logged: true, message: e.message, backtrace: e.backtrace }.to_json
              end
            end
          end
        end
      end
    end
  end
end
