module Obscured
  module Helpers
    module SlackHelper
      def slack_client
        Slack::Notifier.new ENV['SLACK_WEBHOOK_URL'] do
          defaults channel: ENV['SLACK_CHANNEL'],
                   username: ENV['SLACK_USER']
        end
      end
    end
  end
end