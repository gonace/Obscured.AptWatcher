# frozen_string_literal: true

module Obscured
  class SystemStateError < StandardError
    def initialize
      super('System is not online.')
    end
  end

  class DomainError < StandardError
    attr_reader :code
    attr_reader :field
    attr_reader :error

    ERRORS = {
      invalid_parameter: 'Missing or invalid parameter {what}',
      invalid_api_method: 'No method parameter was supplied',
      unspecified_error: 'Unspecified error',
      already_exists: '{what}',
      does_not_exist: '{what}',
      does_not_match: '{what}',
      invalid_date: 'Cannot parse {what} from: {date}',
      invalid_type: '{what}',
      not_active: 'Not active',
      required_field_missing: 'Required field {field} is missing'
    }.freeze

    def initialize(code, params = {})
      field = params.delete(:field)
      error = params.delete(:error)

      super(parse(code, params))
      @code = code || :unspecified_error
      @field = field || :unspecified_field
      @error = error
    end


    private

    def parse(code, params = {})
      message = ERRORS[code]
      params.each_pair do |key,value|
        message = message.sub("{#{key}}", value)
      end
      message
    end
  end

  class AccountNotFoundError < DomainError
    def initialize
      super(:invalid_account, what: 'Could not find account')
    end
  end

  class AccountNotActiveError < DomainError
    def initialize
      super(:not_active)
    end
  end

  class InvalidPasswordError < DomainError
    attr_reader :attempts_left

    def initialize(attempts_left)
      @attempts_left = attempts_left
      super(:invalid_password, error: { attempts_left: attempts_left })
    end
  end

  class InvalidFieldError < ArgumentError
    attr_reader :field

    def initialize(field, message = nil)
      @field = field
      super(message || "Invalid value for field #{field}.")
    end
  end
end
