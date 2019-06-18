module Obscured
  module AptWatcher
    module Configurable
      def config
        @config if defined?(@config)
      end

      def config=(config)
        @config = config
      end
    end
  end
end