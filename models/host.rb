module Obscured
  module AptWatcher
    module Models
      class Host
        include Mongoid::Document
        include Mongoid::Timestamps
        store_in collection: 'hosts'

        field :hostname,              type: String
        field :description,           type: String, :default => ''
        field :environment,           type: String, :default => ENV['RACK_ENV']
        field :updates_pending,       type: Integer, :default => 0
        field :updates_installed,     type: Integer, :default => 0

        before_save :validate!

        def self.make(opts)
          raise Obscured::DomainError.new(:required_field_missing, what: ':hostname') if opts[:hostname].empty?

          if Host.where(:hostname => opts[:hostname]).exists?
            raise Obscured::DomainError.new(:already_exists, what: 'host')
          end

          host = self.new
          host.hostname = opts[:hostname]
          host.environment = opts[:environment]

          host
        end

        def self.make_and_save(opts)
          host = self.make(opts)
          host.save

          host
        end


        def set_updates_pending(opts)
          #raise Obscured::DomainError.new(:required_field_missing, what: ':packages') if opts[:packages].empty?
          raise Obscured::DomainError.new(:invalid_type, what: ':packages') unless opts[:packages].kind_of?(Array)

          #self.updates_pending = opts[:packages].count rescue 0
          self.updates_pending = opts[:packages].select {|i| i['installed'] == false || !i.key?('installed')}.count
        end
        def set_updates_installed(opts)
          #raise Obscured::DomainError.new(:required_field_missing, what: ':packages') if opts[:packages].empty?
          raise Obscured::DomainError.new(:invalid_type, what: ':packages') unless opts[:packages].kind_of?(Array)

          #self.updates_installed = opts[:packages].count rescue 0
          self.updates_pending = opts[:packages].select {|i| i['installed'] == true}.count
        end
      end
    end
  end
end
