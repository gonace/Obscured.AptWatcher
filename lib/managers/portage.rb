require_relative 'manager'

module Obscured
  module AptWatcher
    module Managers
      class Portage < Manager
        def initialize
          Portage.config = Obscured::AptWatcher::Models::Configuration.where(type: :manager, signature: :portage).find_first
        end


        def reinitialize
          Obscured::AptWatcher::Managers.unregister(self.class)
          Obscured::AptWatcher::Managers.register(self.class)
        end

        def name
          'Portage'
        end

        def type
          :manager
        end

        def enabled?
          !Portage.config.nil? and Portage.config.properties[:enabled] == true
        end

        def installed?
          !Portage.config.nil?
        end

        def install(config)
          if Portage.config.nil?
            Obscured::AptWatcher::Models::Configuration.make!(type: :manager, signature: :portage, properties: config)
            reinitialize
          end
        end

        def uninstall
          Obscured::AptWatcher::Models::Configuration.where(type: :manager, signature: :portage).delete
          reinitialize
        end

        def config
          Portage.config unless Portage.config.nil?
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
Obscured::AptWatcher::Managers.register(Obscured::AptWatcher::Managers::Portage)