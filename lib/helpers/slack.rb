module Obscured
  module Helpers
    module SlackHelper
      def slack_client
        config = Obscured::AptWatcher::Models::Configuration.where({:instance => 'aptwatcher'}).first
        webhook = config.slack.webhook rescue ''
        channel = config.slack.channel rescue ''
        username = config.slack.user rescue ''


        Slack::Notifier.new webhook do
          defaults channel: channel,
                   username: username
        end
      end
    end
  end
end