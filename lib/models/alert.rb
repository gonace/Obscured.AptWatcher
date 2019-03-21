module Obscured
  module AptWatcher
    module Models
      class Alert
        include Mongoid::Document
        include Mongoid::Timestamps
        include Mongoid::Search
        include Obscured::AptWatcher::Models::TrackedEntity

        store_in collection: 'alerts'

        field :hostname, type: String
        field :message, type: String, :default => ''
        field :backtrace, type: String
        field :status, type: String, :default => Obscured::Status::OPEN
        field :type, type: String, :default => Obscured::Alert::Type::SYSTEM
        field :notify, type: Boolean, :default => true
        field :payload, type: String

        index({ hostname: 1 }, { background: true })
        index({ status: 1 }, { background: true })
        index({ type: 1 }, { background: true })

        search_in :hostname, :status, :type

        before_save :validate!


        class << self
          def make(opts)
            raise Obscured::DomainError.new(:required_field_missing, what: ':hostname') if opts[:hostname].empty?
            raise Obscured::DomainError.new(:required_field_missing, what: ':message') if opts[:message].empty?

            doc = self.new
            doc.hostname = opts[:hostname]
            doc.message = opts[:message]

            unless opts[:backtrace].nil?
              raise Obscured::DomainError.new(:invalid_type, what: ':backtrace') unless opts[:backtrace].kind_of?(String)
              doc.backtrace = opts[:backtrace]
            end
            unless opts[:status].nil?
              raise Obscured::DomainError.new(:invalid_type, what: ':status') unless opts[:status].kind_of?(Obscured::Status)
              doc.status = opts[:status]
            end
            unless opts[:type].nil?
              doc.type = opts[:type]
            end
            unless opts[:notify].nil?
              raise Obscured::DomainError.new(:invalid_type, what: ':notify') unless opts[:notify].kind_of?(Boolean)
              doc.notify = opts[:notify]
            end
            unless opts[:payload].nil?
              doc.payload = opts[:payload].to_s
            end
            doc
          end
          def make!(opts)
            doc = self.make(opts)
            doc.save
            doc
          end
        end


        def set_status(status)
          raise Obscured::DomainError.new(:required_field_missing, what: ':status') if status.empty?
          raise Obscured::DomainError.new(:invalid_type, what: ':status') unless status.kind_of?(Obscured::Status)
          self.status = status
        end

        def set_type(type)
          raise Obscured::DomainError.new(:required_field_missing, what: ':type') if type.empty?
          raise Obscured::DomainError.new(:invalid_type, what: ':type') unless type.kind_of?(Obscured::Alert::Type)
          self.type = type
        end
      end
    end
  end
end
