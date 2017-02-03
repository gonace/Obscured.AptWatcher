module Obscured
  module Doorman
    module Utilities
      include Obscured::Doorman::Types

      class CreatedFrom
        def self.valid_account_created_from?(created_from)
          valid = []
          CreatedFrom.constants.each do |constant|
            valid << CreatedFrom.const_get(constant)
          end
          valid.include?(created_from)
        end
        def self.to_created_from_const(created_from)
          raise Obscured::Doorman::DomainError.new(:invalid_created_from, :what => "to_const does not support given argument => #{created_from}")
        end
      end
    end
  end
end