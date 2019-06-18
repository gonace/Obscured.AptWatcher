module Obscured
  module AptWatcher
    module Models
      class Gateway
        include Mongoid::Document
        include Mongoid::Properties
        include Mongoid::Timeline::Tracker
        include Mongoid::Timestamps

        store_in collection: 'gateways'

        field :hostname, type: String
        field :username, type: String
        field :password, type: String

        index({ hostname: 1 }, { background: true })


        class << self
          def make(opts)
            raise Obscured::DomainError.new(:required_field_missing, what: ':hostname') if opts[:hostname].empty?
            raise Obscured::DomainError.new(:already_exists, what: 'host') if Gateway.where(:hostname => opts[:hostname]).exists?

            doc = self.new
            doc.hostname = opts[:hostname]
            opts[:properties].each { |k, v| doc.set_property(k, v) } unless opts[:properties].nil?
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