module Obscured
  module AptWatcher
    module Managers
      @managers = []

      class << self
        def register(klass)
          @managers << klass.new
        end

        def unregister(klass)
          @managers.reject! { |m| m.is_a?(klass) }
        end

        def get(signature)
          @managers.detect { |m| m.signature.equal?(signature) }
        end

        def call(signature, method, *args)
          @managers.select { |m| m.signature.equal?(signature) }.each do |manager|
            return manager.send(method, *args)
          end
        end

        def all
          @managers
        end

        def reset
          @managers = []
        end
      end
    end
  end
end

require_relative 'managers/apt'
require_relative 'managers/pacman'
require_relative 'managers/portage'
require_relative 'managers/rpm'
require_relative 'managers/yum'