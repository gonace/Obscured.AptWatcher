# frozen_string_literal: true

require 'symmetric_encryption'

module Obscured
  module AptWatcher
    module Models
      class Gateway
        include Mongoid::Document
        include Mongoid::Status
        include Mongoid::Tags
        include Mongoid::Heartbeat::Tracker
        include Mongoid::Timeline::Tracker
        include Mongoid::Timestamps

        store_in collection: 'gateways'

        field :name, type: String
        field :hostname, type: String
        field :username, type: String
        field :encrypted_password, type: String, encrypted: { random_iv: true }

        index({ hostname: 1 }, background: true)


        class << self
          def make(opts)
            raise Obscured::DomainError.new(:required_field_missing, what: 'name') if opts[:name].empty?
            raise Obscured::DomainError.new(:required_field_missing, what: 'hostname') if opts[:hostname].empty?
            raise Obscured::DomainError.new(:already_exists, what: 'hostname') if Gateway.where(hostname: opts[:hostname]).exists?

            doc = new
            doc.name = opts[:name]
            doc.hostname = opts[:hostname]
            doc.username = opts[:username]
            doc.password = opts[:password]
            doc
          end

          def make!(opts)
            doc = make(opts)
            doc.save
            doc
          end
        end
      end
    end
  end
end
