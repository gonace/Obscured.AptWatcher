module Obscured
  module AptWatcher
    module Models
      class Host
        include Mongoid::Document
        include Mongoid::State
        include Mongoid::Status
        include Mongoid::Tags
        include Mongoid::Timeline::Tracker
        include Mongoid::Timestamps

        store_in collection: 'hosts'

        field :name, type: String
        field :hostname, type: String
        field :manager, type: Symbol
        field :description, type: String, :default => ''
        field :pending, type: Integer, :default => 0
        field :installed, type: Integer, :default => 0

        has_many :scans

        index({ hostname: 1 }, { background: true })


        class << self
          def make(opts)
            raise Obscured::DomainError.new(:required_field_missing, what: 'name') if opts[:name].empty?
            raise Obscured::DomainError.new(:required_field_missing, what: 'hostname') if opts[:hostname].empty?
            raise Obscured::DomainError.new(:required_field_missing, what: 'manager') if opts[:manager].empty?
            raise Obscured::DomainError.new(:already_exists, what: 'hostname') if Host.where(:hostname => opts[:hostname]).exists?

            doc = self.new
            doc.name = opts[:name]
            doc.hostname = opts[:hostname]
            doc.manager = opts[:manager]
            doc
          end
          def make!(opts)
            doc = self.make(opts)
            doc.save
            doc
          end
        end

        def set_updates_pending(opts)
          raise Obscured::DomainError.new(:invalid_type, what: ':packages') unless opts[:packages].kind_of?(Array)
          self.pending = opts[:packages].select {|i| i['installed'] == false || !i.key?('installed')}.count
        end

        def set_updates_installed(opts)
          raise Obscured::DomainError.new(:invalid_type, what: ':packages') unless opts[:packages].kind_of?(Array)
          self.installed = opts[:packages].select {|i| i.key?('installed') && i['installed'] == true}.count
        end
      end
    end
  end
end
