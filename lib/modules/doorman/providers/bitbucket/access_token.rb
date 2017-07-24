module Obscured
  module Doorman
    module Providers
      module Bitbucket
        class AccessToken
          include ActiveModel::Model
          attr_accessor :access_token
          attr_accessor :refresh_token
          attr_accessor :scopes
          attr_accessor :expires_in
          attr_accessor :expires_date
          attr_accessor :emails
          validates :access_token, :refresh_token, :scopes, :expires_in, presence: true

          def initialize(attributes={})
            super
            @expires_date = DateTime.now + self.expires_in.to_i.seconds
          end
        end
      end
    end
  end
end