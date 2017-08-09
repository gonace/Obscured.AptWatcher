module Obscured
  module Doorman
    module Providers
      module GitHub
        class AccessToken
          include ActiveModel::Model
          attr_accessor :access_token
          #attr_accessor :refresh_token
          attr_accessor :token_type
          attr_accessor :scope
          #attr_accessor :expires_in
          #attr_accessor :expires_date
          attr_accessor :emails
          validates :access_token, :scope, presence: true

          def initialize(attributes={})
            super
            #@expires_date = DateTime.now + self.expires_in.to_i.seconds
          end
        end
      end
    end
  end
end