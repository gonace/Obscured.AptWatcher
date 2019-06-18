require_relative 'plugin'

module Obscured
  module AptWatcher
    module Plugins
      class RayGun < Plugin
        def initialize
          RayGun.config = Obscured::AptWatcher::Models::Configuration.where(type: :plugin, signature: :raygun).find_first
        end


        def name
          'RayGun'
        end

        def category
          'Error Tracker'
        end

        def type
          :plugin
        end

        def installed?
          !RayGun.config.nil?
        end

        def config
          {
            enabled: { type: "checkbox", placeholder: "", value: true },
            key: { type: "text", placeholder: "", value: "" }
          }
        end

        def version
          '0.0.1'.freeze
        end
      end
    end
  end
end
Obscured::AptWatcher::Plugins.register(Obscured::AptWatcher::Plugins::RayGun)