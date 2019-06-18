require_relative 'plugin'

module Obscured
  module AptWatcher
    module Plugins
      class Bitbucket < Plugin
        def initialize
          Bitbucket.config = Obscured::AptWatcher::Models::Configuration.where(type: :plugin, signature: :bitbucket).find_first
        end


        def name
          'BitBucket'
        end

        def category
          'Authentication'
        end

        def type
          :plugin
        end

        def installed?
          !Bitbucket.config.nil?
        end

        def install
          if Bitbucket.config.nil?
            Obscured::AptWatcher::Models::Configuration.make!(type: :plugin, signature: :bitbucket, properties: config)
          end
        end

        def config
          {
            enabled: { type: "checkbox", placeholder: "", value: true },
            key: { type: "text", placeholder: "", value: "" },
            secret: { type: "password", placeholder: "", value: "" },
            domains: { type: "tags", placeholder: "", value: "" }
          }
        end

        def version
          '0.0.1'.freeze
        end
      end
    end
  end
end
Obscured::AptWatcher::Plugins.register(Obscured::AptWatcher::Plugins::Bitbucket)