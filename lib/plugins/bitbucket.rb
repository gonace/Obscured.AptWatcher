require_relative 'plugin'

module Obscured
  module AptWatcher
    module Plugins
      class Bitbucket < Plugin
        def name
          'Bitbucket'
        end

        def type
          :authentication
        end

        def template
          {
            enabled: { type: "checkbox", placeholder: "", value: true },
            key: { type: "text", placeholder: "", value: "" },
            secret: { type: "password", placeholder: "", value: "" },
            domains: { type: "tags", placeholder: "", value: "" }
          }
        end

        def version
          '0.0.1'.freeze
        end
      end
    end
  end
end
Obscured::AptWatcher::Plugins.register(Obscured::AptWatcher::Plugins::Bitbucket)