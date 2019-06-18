require_relative 'manager'

module Obscured
  module AptWatcher
    module Managers
      class APT < Manager
        def initialize
          APT.config = Obscured::AptWatcher::Models::Configuration.where(type: :manager, signature: :apt).find_first
        end


        def reinitialize
          Obscured::AptWatcher::Managers.unregister(self.class)
          Obscured::AptWatcher::Managers.register(self.class)
        end

        def name
          'APT'
        end

        def type
          :manager
        end

        def enabled?
          !APT.config.nil? and APT.config.properties[:enabled] == true
        end

        def installed?
          !APT.config.nil?
        end

        def install(config)
          if APT.config.nil?
            Obscured::AptWatcher::Models::Configuration.make!(type: :manager, signature: :apt, properties: config)
            reinitialize
          end
        end

        def uninstall
          Obscured::AptWatcher::Models::Configuration.where(type: :manager, signature: :apt).delete
          reinitialize
        end

        def config
          APT.config
        end

        def template
          {
            enabled: { type: "checkbox", placeholder: "", value: true }
          }
        end

        def version
          '1.0.0'.freeze
        end
      end
    end
  end
end
Obscured::AptWatcher::Managers.register(Obscured::AptWatcher::Managers::APT)