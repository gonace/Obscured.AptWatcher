require_relative 'plugin'

module Obscured
  module AptWatcher
    module Plugins
      class Slack < Plugin
        def initialize
          Slack.config = Obscured::AptWatcher::Models::Configuration.where(type: :plugin, signature: :slack).find_first
        end


        def name
          'Slack'
        end

        def category
          'Notifications'
        end

        def type
          :plugin
        end

        def installed?
          !Slack.config.nil?
        end

        def config
          {
            enabled: { type: "checkbox", placeholder: "", value: true },
            channel: { type: "text", placeholder: "", value: "" },
            icon: { type: "text", placeholder: "", value: "" },
            user: { type: "text", placeholder: "", value: "" },
            webhook: { type: "text", placeholder: "", value: "" }
          }
        end

        def version
          '0.0.1'.freeze
        end
      end
    end
  end
end
Obscured::AptWatcher::Plugins.register(Obscured::AptWatcher::Plugins::Slack)