# frozen_string_literal: true

require_relative 'manager'

module Obscured
  module AptWatcher
    module Managers
      class APT < Manager
        def name
          'APT'
        end

        def template
          {
            enabled: { type: 'checkbox', placeholder: '', value: true }
          }
        end

        def version
          '1.0.0'
        end
      end
    end
  end
end
Obscured::AptWatcher::Managers.register(Obscured::AptWatcher::Managers::APT)
