# frozen_string_literal: true

require_relative 'manager'

module Obscured
  module AptWatcher
    module Managers
      class Pacman < Manager
        def name
          'Pacman'
        end

        def template
          {
            enabled: { type: 'checkbox', placeholder: '', value: true }
          }
        end

        def version
          '0.0.1'
        end
      end
    end
  end
end
Obscured::AptWatcher::Managers.register(Obscured::AptWatcher::Managers::Pacman)