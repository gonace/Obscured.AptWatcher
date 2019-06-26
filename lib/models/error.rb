# frozen_string_literal: true

module Obscured
  module AptWatcher
    module Models
      class Error
        include Mongoid::Document
        include Mongoid::Timestamps

        store_in collection: 'errors'

        field :notifier, type: String
        field :message, type: String, default: ''
        field :backtrace, type: String
        field :status, type: String, default: Obscured::Status::OPEN
        field :type, type: String, default: Obscured::Alert::Type::SYSTEM


        class << self
          def make(opts)
            raise Obscured::DomainError.new(:required_field_missing, what: ':notifier') if opts[:notifier].empty?
            raise Obscured::DomainError.new(:required_field_missing, what: ':message') if opts[:message].empty?

            entity = new
            entity.notifier = opts[:notifier]
            entity.message = opts[:message]

            unless opts[:backtrace].nil?
              raise Obscured::DomainError.new(:invalid_type, what: ':backtrace') unless opts[:backtrace].kind_of?(String)
              entity.backtrace = opts[:backtrace]
            end
            unless opts[:status].nil?
              raise Obscured::DomainError.new(:invalid_type, what: ':status') unless opts[:status].kind_of?(Obscured::Status)
              entity.status = opts[:status]
            end
            unless opts[:type].nil?
              raise Obscured::DomainError.new(:invalid_type, what: ':type') unless opts[:type].kind_of?(Obscured::Alert::Type)
              entity.type = opts[:type]
            end
            entity
          end
          def make!(opts)
            entity = make(opts)
            entity.save
            entity
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
