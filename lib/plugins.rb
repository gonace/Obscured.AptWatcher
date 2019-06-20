module Obscured
  module AptWatcher
    module Plugins
      @plugins = []

      class << self
        def register(klass)
          @plugins << klass.new
        end

        def unregister(klass)
          @plugins.reject! { |m| m.is_a?(klass) }
        end

        def get(signature)
          @plugins.detect { |e| e.signature.equal?(signature) }
        end

        def call(signature, method, *args)
          @plugins.select { |e| e.signature.equal?(signature) }.each do |plugin|
            return plugin.send(method, *args)
          end
        end

        def all
          @plugins
        end

        def reset
          @plugins = []
        end
      end
    end
  end
end

require_relative 'plugins/acl'
require_relative 'plugins/api'
require_relative 'plugins/bitbucket'
require_relative 'plugins/github'
require_relative 'plugins/raygun'
require_relative 'plugins/sendgrid'
require_relative 'plugins/slack'
require_relative 'plugins/smtp'