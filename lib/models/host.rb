module Obscured
  module AptWatcher
    module Models
      class Host
        include Mongoid::Document
        include Mongoid::State
        include Mongoid::Timeline::Tracker
        include Mongoid::Timestamps

        store_in collection: 'hosts'

        field :hostname,              type: String
        field :description,           type: String, :default => ''
        field :environment,           type: String, :default => ENV['RACK_ENV']
        field :group,                 type: String, :default => ''
        field :updates_pending,       type: Integer, :default => 0
        field :updates_installed,     type: Integer, :default => 0

        index({ hostname: 1 }, { background: true })


        class << self
          def make(opts)
            raise Obscured::DomainError.new(:required_field_missing, what: ':hostname') if opts[:hostname].empty?

            if Host.where(:hostname => opts[:hostname]).exists?
              raise Obscured::DomainError.new(:already_exists, what: 'host')
            end

            doc = self.new
            doc.hostname = opts[:hostname]

            unless opts[:environment].nil?
              raise Obscured::DomainError.new(:invalid_type, what: ':environment') unless opts[:environment].kind_of?(String)
              doc.environment = opts[:environment]
            end

            unless opts[:hostname].nil?
              if opts[:hostname].include?('production') ||
                 opts[:hostname].include?('prod')
                doc.environment = :production
              elsif opts[:hostname].include?('staging') ||
                    opts[:hostname].include?('stage')
                doc.environment = :staging
              elsif opts[:hostname].include?('testing') ||
                    opts[:hostname].include?('test') ||
                    opts[:hostname].include?('qa')
                doc.environment = :test
              elsif opts[:hostname].include?('shared')
                doc.environment = :shared
              elsif opts[:hostname].include?('development') ||
                    opts[:hostname].include?('dev') ||
                    opts[:hostname].include?('local')
                doc.environment = :development
              end
            end
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
