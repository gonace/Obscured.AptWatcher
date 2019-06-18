module Obscured
  module AptWatcher
    module Plugins
      @plugins = []

      class << self
        def register(klass)
          @plugins << klass.new
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