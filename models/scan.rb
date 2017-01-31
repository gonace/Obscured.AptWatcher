module Obscured
  module AptWatcher
    module Models
      class Scan
        include Mongoid::Document
        include Mongoid::Timestamps
        store_in collection: 'scans'

        field :hostname,              type: String
        field :packages,              type: Array
        field :updates_pending,       type: Integer, :default => 0

        before_save :validate!

        def self.make(opts)
          raise Obscured::DomainError.new(:required_field_missing, what: ':hostname') if opts[:hostname].empty?
          #raise Obscured::DomainError.new(:required_field_missing, what: ':packages') if opts[:packages].empty?
          raise Obscured::DomainError.new(:invalid_type, what: ':packages') unless opts[:packages].kind_of?(Array)


          scan = self.new
          scan.hostname = opts[:hostname]
          scan.packages = opts[:packages]
          scan.updates_pending = opts[:packages].select {|i| i['installed'] == false || !i.key?('installed')}.count

          scan
        end

        def self.make_and_save(opts)
          scan = self.make(opts)
          scan.save

          scan
        end


        def set_updates_pending(opts)
          #raise Obscured::DomainError.new(:required_field_missing, what: ':packages') if opts[:packages].empty?
          raise Obscured::DomainError.new(:invalid_type, what: ':packages') unless opts[:packages].kind_of?(Array)

          self.updates_pending = opts[:packages].select {|i| i['installed'] == false || !i.key?('installed')}.count
        end


        def get_pending
          self.packages.select {|i| i['installed'] == false || !i.key?('installed')}
        end
        def get_installed
          self.packages.select {|i| i['installed'] == true}
        end
      end
    end
  end
end
