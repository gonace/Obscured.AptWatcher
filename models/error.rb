module Obscured
  module AptWatcher
    module Models
      class Error
        include Mongoid::Document
        include Mongoid::Timestamps
        store_in collection: 'errors'

        field :notifier,              type: String
        field :message,               type: String, :default => ''
        field :backtrace,             type: String
        field :status,                type: String, :default => Obscured::Status::OPEN
        field :type,                  type: String, :default => Obscured::Alert::Type::SYSTEM

        before_save :validate!

        def self.make(opts)
          raise Obscured::DomainError.new(:required_field_missing, what: ':notifier') if opts[:notifier].empty?
          raise Obscured::DomainError.new(:required_field_missing, what: ':message') if opts[:message].empty?


          alert = self.new
          alert.notifier = opts[:notifier]
          alert.message = opts[:message]


          unless opts[:backtrace].nil?
            raise Obscured::DomainError.new(:invalid_type, what: ':backtrace') unless opts[:backtrace].kind_of?(String)
            alert.backtrace = opts[:backtrace]
          end
          unless opts[:status].nil?
            raise Obscured::DomainError.new(:invalid_type, what: ':status') unless opts[:status].kind_of?(Obscured::Status)
            alert.status = opts[:status]
          end
          unless opts[:type].nil?
            raise Obscured::DomainError.new(:invalid_type, what: ':type') unless opts[:type].kind_of?(Obscured::Alert::Type)
            alert.type = opts[:type]
          end

          alert
        end

        def self.make_and_save(opts)
          alert = self.make(opts)
          alert.save

          alert
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
