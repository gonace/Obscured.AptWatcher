module Obscured
  module AptWatcher
    module Models
      class Scan
        include Mongoid::Document
        include Mongoid::Timestamps
        include Mongoid::Search
        include Obscured::AptWatcher::Models::TrackedEntity

        store_in collection: 'scans'

        field :hostname, type: String
        field :packages, type: Array
        field :updates_pending, type: Integer, :default => 0
        field :updates_installed, type: Integer, :default => 0

        index({ hostname: 1 }, { background: true })
        index({ created_at: 1}, { background: true, expire_after_seconds: 31536000 })

        search_in :hostname

        before_save :validate!


        class << self
          def make(opts)
            raise Obscured::DomainError.new(:required_field_missing, what: ':hostname') if opts[:hostname].empty?
            raise Obscured::DomainError.new(:invalid_type, what: ':packages') unless opts[:packages].kind_of?(Array)

            doc = self.new
            doc.hostname = opts[:hostname]
            doc.packages = opts[:packages]
            doc.updates_pending = opts[:packages].select {|i| i['installed'] == false || !i.key?('installed')}.count
            doc.updates_installed = opts[:packages].select {|i| i.key?('installed') && i['installed'] == true}.count
            doc
          end
          def make!(opts)
            doc = self.make(opts)
            doc.save
            doc
          end
        end

        def get_pending
          self.packages.select {|i| !i['installed'] || !i.key?('installed')}
        end

        def get_installed
          self.packages.select {|i| i['installed']}
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
