module Obscured
  module AptWatcher
    module Models
      class Scan
        include Mongoid::Document
        include Mongoid::Timestamps
        include Obscured::AptWatcher::Models::TrackedEntity
        store_in collection: 'scans'

        field :hostname,              type: String
        field :packages,              type: Array
        field :updates_pending,       type: Integer, :default => 0
        field :updates_installed,     type: Integer, :default => 0

        index({ hostname: 1 }, { background: true })
        index({ created_at: 1}, { background: true, expire_after_seconds: 31536000 })

        before_save :validate!


        def self.make(opts)
          raise Obscured::DomainError.new(:required_field_missing, what: ':hostname') if opts[:hostname].empty?
          raise Obscured::DomainError.new(:invalid_type, what: ':packages') unless opts[:packages].kind_of?(Array)

          entity = self.new
          entity.hostname = opts[:hostname]
          entity.packages = opts[:packages]
          entity.updates_pending = opts[:packages].select {|i| i['installed'] == false || !i.key?('installed')}.count
          entity.updates_installed = opts[:packages].select {|i| i.key?('installed') && i['installed'] == true}.count
          entity
        end

        def self.make_and_save(opts)
          entity = self.make(opts)
          entity.save
          entity
        end

        def get_pending
          self.packages.select {|i| i['installed'] == false || !i.key?('installed')}
        end

        def get_installed
          self.packages.select {|i| i['installed'] == true}
        end


        def set_updates_pending(opts)
          raise Obscured::DomainError.new(:invalid_type, what: ':packages') unless opts[:packages].kind_of?(Array)
          self.updates_pending = opts[:packages].select {|i| i['installed'] == false || !i.key?('installed')}.count
        end

        def set_updates_installed(opts)
          raise Obscured::DomainError.new(:invalid_type, what: ':packages') unless opts[:packages].kind_of?(Array)
          self.updates_installed = opts[:packages].select {|i| i.key?('installed') && i['installed'] == true}.count
        end
      end
    end
  end
end
