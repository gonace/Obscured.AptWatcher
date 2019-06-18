require_relative 'manager'

module Obscured
  module AptWatcher
    module Managers
      class YUM < Manager
        def initialize
          YUM.config = Obscured::AptWatcher::Models::Configuration.where(type: :manager, signature: :yum).find_first
        end


        def reinitialize
          Obscured::AptWatcher::Managers.unregister(self.class)
          Obscured::AptWatcher::Managers.register(self.class)
        end

        def name
          'YUM'
        end

        def type
          :manager
        end

        def enabled?
          !YUM.config.nil? and YUM.config.properties[:enabled] == true
        end

        def installed?
          !YUM.config.nil?
        end

        def install(config)
          if YUM.config.nil?
            Obscured::AptWatcher::Models::Configuration.make!(type: :manager, signature: :yum, properties: config)
            reinitialize
          end
        end

        def uninstall
          Obscured::AptWatcher::Models::Configuration.where(type: :manager, signature: :yum).delete
          reinitialize
        end

        def config
          YUM.config unless YUM.config.nil?
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
Obscured::AptWatcher::Managers.register(Obscured::AptWatcher::Managers::YUM)