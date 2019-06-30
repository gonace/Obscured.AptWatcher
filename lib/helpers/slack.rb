# frozen_string_literal: true

module Obscured
  module Helpers
    module SlackHelper
      def slack_client
        config = Obscured::AptWatcher::Models::Configuration.where(instance: 'aptwatcher').first
        webhook = config.slack&.webhook
        channel = config.slack&.channel
        username = config.slack&.user


        Slack::Notifier.new webhook do
          defaults channel: channel,
                   username: username
        end
      end
    end
  end
end
