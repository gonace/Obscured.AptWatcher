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
                if host.nil?
                  host = Obscured::AptWatcher::Models::Host.make_and_save({:hostname => hostname})
                end

                request.body.rewind
                packages = []
                request.body.read.each_line do |package|
                  packages.push JSON.parse(package)
                end

                host.set_updates_pending({ :packages => packages })
                host.save!

                scan = Obscured::AptWatcher::Models::Scan.make_and_save({:hostname => hostname, :packages => packages})

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
                unless scan.packages.count == 0
                  slack_client.post icon_emoji: scan.packages.count > 10 ? ':bug-error:' : ':bug-warn:', attachments: attachments
                  Obscured::AptWatcher::Models::Alert.make_and_save({ :hostname => hostname, :type => Obscured::Alert::Type::SYSTEM, :message => "There are #{scan.packages.count} available updates for this host", :payload => attachments })

                  date_start = Date.yesterday.strftime('%Y-%m-%d')
                  date_end = Date.today.strftime('%Y-%m-%d')
                  Obscured::AptWatcher::Package::Matcher.run(hostname, date_start.to_s, date_end).to_json
                else
                  alerts = Obscured::AptWatcher::Models::Alert.where(:hostname => hostname, :type => Obscured::Alert::Type::SYSTEM)

                  alerts.each do |alert|
                    alert.status = Obscured::Status::CLOSED
                    alert.save
                  end
                end

                scan
              rescue => e
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
                slack_client.post icon_emoji: ':bug-error:', attachments: attachments

                Obscured::AptWatcher::Models::Error.make_and_save({ :notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />'), :payload => attachments })
                {:success => false, :logged => true, :message => e.message, :backtrace => e.backtrace}.to_json
              end
            end
          end
        end
      end
    end
  end
end