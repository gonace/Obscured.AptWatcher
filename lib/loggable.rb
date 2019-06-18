module Obscured
  module AptWatcher
    module Loggable
      def logger
        return @logger if defined?(@logger)
        @logger = default_logger
      end

      def logger=(logger)
        @logger = logger
      end


      private

      def default_logger
        logger = Logger.new($stdout)
        logger.level = Logger::DEBUG
        logger
      end
    end
  end
end