# frozen_string_literal: true

require_relative 'plugin'

module Obscured
  module AptWatcher
    module Plugins
      class SMTP < Plugin
        def name
          'SMTP'
        end

        def type
          :notifications
        end

        def template
          {
            enabled: { type: 'checkbox', placeholder: '', value: true },
            domain: { type: 'text', placeholder: 'domain.tld', value: '' },
            host: { type: 'text', placeholder: 'smtp.domain.tld', value: '' },
            port: { type: 'text', placeholder: 587, value: '' },
            username: { type: 'text', placeholder: '', value: '' },
            password: { type: 'password', placeholder: '', value: '' }
          }
        end

        def version
          '0.0.1'
        end
      end
    end
  end
end
Obscured::AptWatcher::Plugins.register(Obscured::AptWatcher::Plugins::SMTP)
