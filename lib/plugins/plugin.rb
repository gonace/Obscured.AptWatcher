require_relative '../models/configuration'

module Obscured
  module AptWatcher
    class Plugin
      extend Configurable

      attr_reader :signature

      def signature
        @signature ||= self.class.name.demodulize.downcase.to_sym
      end

      def name
        raise NotImplementedError
      end

      def category
        raise NotImplementedError
      end

      def type
        raise NotImplementedError
      end

      def installed?
        raise NotImplementedError
      end

      def install
        raise NotImplementedError
      end

      def version
        raise NotImplementedError
      end
    end
  end
end