require_relative 'manager'

module Obscured
  module AptWatcher
    module Managers
      class Pacman < Manager
        def initialize
          Pacman.config = Obscured::AptWatcher::Models::Configuration.where(type: :manager, signature: :pacman).find_first
        end


        def reinitialize
          Obscured::AptWatcher::Managers.unregister(self.class)
          Obscured::AptWatcher::Managers.register(self.class)
        end

        def name
          'Pacman'
        end

        def type
          :manager
        end

        def enabled?
          !Pacman.config.nil? and Pacman.config.properties[:enabled] == true
        end

        def installed?
          !Pacman.config.nil?
        end

        def install(config)
          if Pacman.config.nil?
            Obscured::AptWatcher::Models::Configuration.make!(type: :manager, signature: :pacman, properties: config)
            reinitialize
          end
        end

        def uninstall
          Obscured::AptWatcher::Models::Configuration.where(type: :manager, signature: :pacman).delete
          reinitialize
        end

        def config
          Pacman.config
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
Obscured::AptWatcher::Managers.register(Obscured::AptWatcher::Managers::Pacman)