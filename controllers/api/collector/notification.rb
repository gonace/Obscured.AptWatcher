module Obscured
  module AptWatcher
    module Controllers
      module Api
        module Collector
          class Notification < Obscured::AptWatcher::Controllers::Api::Base
            post '/:name' do |hostname|
              content_type :json

              hostname.gsub!(/[^a-zA-Z0-9\.\-_]/, '')
              begin
                throw NotImplementedError
              rescue => e
                attachments = [{
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
                }]
                slack_client.post icon_emoji: ':bug-error:', attachments: attachments

                Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
                {:success => false, :logged => true, :message => e.message, :backtrace => e.backtrace}.to_json
              end
            end
          end
        end
      end
    end
  end
end