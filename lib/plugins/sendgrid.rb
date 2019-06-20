require_relative 'plugin'

module Obscured
  module AptWatcher
    module Plugins
      class SendGrid < Plugin
        def name
          'SendGrid'
        end

        def type
          :notifications
        end

        def template
          {
            enabled: { type: "checkbox", placeholder: "", value: true },
            domain: { type: "text", placeholder: "domain.tld", value: "" },
            host: { type: "text", placeholder: "smtp.sendgrid.net", value: "smtp.sendgrid.net" },
            port: { type: "text", placeholder: 587, value: 587 },
            username: { type: "text", placeholder: "", value: "" },
            password: { type: "password", placeholder: "", value: "" }
          }
        end

        def version
          '0.0.1'.freeze
        end
      end
    end
  end
end
Obscured::AptWatcher::Plugins.register(Obscured::AptWatcher::Plugins::SendGrid)