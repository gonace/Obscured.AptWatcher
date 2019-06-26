# frozen_string_literal: true

module Obscured
  module AptWatcher
    module Models
      class Scan
        include Mongoid::Document
        include Mongoid::Timestamps

        store_in collection: 'scans'

        field :hostname, type: String
        field :packages, type: Array
        field :pending, type: Integer, default: 0
        field :installed, type: Integer, default: 0

        belongs_to :host

        index({ hostname: 1 }, background: true)
        index({ created_at: 1}, background: true, expire_after_seconds: 31536000)


        class << self
          def make(opts)
            raise Obscured::DomainError.new(:required_field_missing, what: ':hostname') if opts[:hostname].empty?
            raise Obscured::DomainError.new(:invalid_type, what: ':packages') unless opts[:packages].kind_of?(Array)

            doc = new
            doc.hostname = opts[:hostname]
            doc.packages = opts[:packages]
            doc.pending = opts[:packages].select { |i| i['installed'] == false || !i.key?('installed') }.count
            doc.installed = opts[:packages].select {| i| i.key?('installed') && i['installed'] == true }.count
            doc
          end

          def make!(opts)
            doc = make(opts)
            doc.save
            doc
          end
        end

        def get_pending
          packages.select { |i| !i['installed'] || !i.key?('installed') }
        end

        def get_installed
          packages.select { |i| i['installed'] }
        end


        def set_updates_pending(opts)
          raise Obscured::DomainError.new(:invalid_type, what: ':packages') unless opts[:packages].kind_of?(Array)

          self.updates_pending = opts[:packages].select { |i| i['installed'] == false || !i.key?('installed') }.count
        end

        def set_updates_installed(opts)
          raise Obscured::DomainError.new(:invalid_type, what: ':packages') unless opts[:packages].kind_of?(Array)

          self.updates_installed = opts[:packages].select { |i| i.key?('installed') && i['installed'] == true }.count
        end
      end
    end
  end
end
