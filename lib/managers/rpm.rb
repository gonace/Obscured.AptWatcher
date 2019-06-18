require_relative 'manager'

module Obscured
  module AptWatcher
    module Managers
      class RPM < Manager
        def initialize
          RPM.config = Obscured::AptWatcher::Models::Configuration.where(type: :manager, signature: :rpm).find_first
        end


        def reinitialize
          Obscured::AptWatcher::Managers.unregister(self.class)
          Obscured::AptWatcher::Managers.register(self.class)
        end

        def name
          'RPM'
        end

        def type
          :manager
        end

        def enabled?
          !RPM.config.nil? and RPM.config.properties[:enabled] == true
        end

        def installed?
          !RPM.config.nil?
        end

        def install(config)
          if RPM.config.nil?
            Obscured::AptWatcher::Models::Configuration.make!(type: :manager, signature: :rpm, properties: config)
            reinitialize
          end
        end

        def uninstall
          Obscured::AptWatcher::Models::Configuration.where(type: :manager, signature: :rpm).delete
          reinitialize
        end

        def config
          RPM.config unless RPM.config.nil?
          {}
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
Obscured::AptWatcher::Managers.register(Obscured::AptWatcher::Managers::RPM)