module Obscured
  module Doorman
    module Strategies
      class Password < Warden::Strategies::Base
        def valid?
          params['user'] &&
              params['user']['login'] &&
              params['user']['password']
        end

        def authenticate!
          user = User.authenticate(params['user']['login'],params['user']['password'])

          if user.nil?
            fail!(Obscured::Doorman::Messages[:login_bad_credentials])
          elsif !user.confirmed
            fail!(Obscured::Doorman::Messages[:login_not_confirmed])
          else
            success!(user)
          end
        end
      end
    end
  end
end