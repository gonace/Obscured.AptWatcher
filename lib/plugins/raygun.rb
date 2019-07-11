# frozen_string_literal: true

require_relative 'plugin'

module Obscured
  module AptWatcher
    module Plugins
      class RayGun < Plugin
        def name
          'RayGun'
        end

        def type
          :plugin
        end

        def template
          {
            enabled: { type: 'checkbox', placeholder: '', value: true },
            key: { type: 'text', placeholder: '', value: '' }
          }
        end

        def version
          '0.0.1'
        end
      end
    end
  end
end
Obscured::AptWatcher::Plugins.register(Obscured::AptWatcher::Plugins::RayGun)
