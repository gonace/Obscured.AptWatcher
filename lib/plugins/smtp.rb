require_relative 'plugin'

module Obscured
  module AptWatcher
    module Plugins
      class SMTP < Plugin
        def initialize
          SendGrid.config = Obscured::AptWatcher::Models::Configuration.where(type: :plugin, signature: :smtp).find_first
        end


        def name
          'SMTP'
        end

        def category
          'Notifications'
        end

        def type
          :plugin
        end

        def installed?
          !SendGrid.config.nil?
        end

        def config
          {
            enabled: { type: "checkbox", placeholder: "", value: true },
            domain: { type: "text", placeholder: "domain.tld", value: "" },
            host: { type: "text", placeholder: "smtp.domain.tld", value: "" },
            port: { type: "text", placeholder: 587, value: "" },
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
Obscured::AptWatcher::Plugins.register(Obscured::AptWatcher::Plugins::SMTP)