# frozen_string_literal: true

require_relative 'plugin'

module Obscured
  module AptWatcher
    module Plugins
      class API < Plugin
        def name
          'API'
        end

        def type
          :integration
        end

        def template
          {
            enabled: { type: 'checkbox', placeholder: '', value: true },
            username: { type: 'text', placeholder: '', value: true },
            password: { type: 'password', placeholder: '', value: true }
          }
        end

        def version
          '0.0.1'
        end
      end
    end
  end
end
Obscured::AptWatcher::Plugins.register(Obscured::AptWatcher::Plugins::API)
