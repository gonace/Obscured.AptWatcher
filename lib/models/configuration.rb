# frozen_string_literal: true

module Obscured
  module AptWatcher
    module Models
      class Configuration
        include Mongoid::Document
        include Mongoid::Timestamps

        store_in collection: 'configurations'

        field :type, type: Symbol
        field :signature, type: Symbol
        field :properties, type: Hash

        index({ type: 1, signature: 1 }, background: true)


        class << self
          def make(opts)
            raise Obscured::DomainError.new(:already_exists, what: "Configuration does already exists for type: #{opts[:type]} and signature: #{opts[:signature]}!") if Configuration.where(type: opts[:type], signature: opts[:signature]).exists?

            doc = new
            doc.type = opts[:type]
            doc.signature = opts[:signature]
            doc.properties = opts[:properties]
            doc
          end

          def make!(opts)
            doc = make(opts)
            doc.save
            doc
          end
        end

        def update_properties(prop)
          self.properties = prop
        end

        def update_properties!(prop)
          self.properties = prop
          save
        end
      end
    end
  end
end
