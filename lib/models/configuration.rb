module Obscured
  module AptWatcher
    module Models
      class Configuration
        include Mongoid::Document
        include Mongoid::Timestamps

        store_in collection: 'configuration'

        field :type, type: Symbol
        field :properties, type: Hash
        field :signature, type: Symbol

        index({ type: 1, signature: 1 }, { background: true })


        class << self
          def make(opts)
            if Configuration.where(type: opts[:type], signature: opts[:signature]).exists?
              raise Obscured::DomainError.new(:already_exists, what: "Configuration does already exists for type: #{opts[:type]} and signature: #{opts[:signature]}!")
            end

            doc = self.new
            doc.type = opts[:type]
            doc.properties = opts[:properties]
            doc.signature = opts[:signature]
            doc
          end
          def make!(opts)
            doc = self.make(opts)
            doc.save
            doc
          end
        end
      end
    end
  end
end