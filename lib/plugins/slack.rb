require_relative 'plugin'

module Obscured
  module AptWatcher
    module Plugins
      class Slack < Plugin
        def name
          'Slack'
        end

        def type
          :notifications
        end

        def template
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