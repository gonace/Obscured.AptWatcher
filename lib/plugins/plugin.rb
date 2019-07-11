# frozen_string_literal: true

require_relative '../models/configuration'

module Obscured
  module AptWatcher
    class Plugin
      def signature
        @signature ||= self.class.name.demodulize.downcase.to_sym
      end

      def config
        Obscured::AptWatcher::Models::Configuration.where(type: type, signature: signature).find_first
      end

      def reinitialize
        Obscured::AptWatcher::Plugins.unregister(self.class)
        Obscured::AptWatcher::Plugins.register(self.class)
      end

      def enabled?
        !config.nil? && config.properties[:enabled] == true
      end

      def installed?
        !config.nil?
      end

      def install(cfg)
        if config.nil?
          Obscured::AptWatcher::Models::Configuration.make!(type: type, signature: signature, properties: cfg)
          reinitialize
        end
      end

      def update(prop)
        config.update_properties!(prop)
      end

      def uninstall
        Obscured::AptWatcher::Models::Configuration.where(type: type, signature: signature).delete
        reinitialize
      end


      # Class implemented methods

      def name
        raise NotImplementedError
      end

      def type
        raise NotImplementedError
      end

      def template
        raise NotImplementedError
      end

      def version
        raise NotImplementedError
      end
    end
  end
end
