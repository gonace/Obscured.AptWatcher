require_relative 'plugin'

module Obscured
  module AptWatcher
    module Plugins
      class ACL < Plugin
        def name
          'ACL'
        end

        def type
          :security
        end

        def template
          {
            enabled: { type: "checkbox", placeholder: "", value: true }
          }
        end

        def version
          '0.0.1'.freeze
        end
      end
    end
  end
end
Obscured::AptWatcher::Plugins.register(Obscured::AptWatcher::Plugins::ACL)