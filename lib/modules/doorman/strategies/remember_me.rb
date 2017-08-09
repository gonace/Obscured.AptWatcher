module Obscured
  module Doorman
    module Strategies
      class RememberMeStrategy < Warden::Strategies::Base
        def valid?
          !!env['rack.cookies'][Obscured::Doorman.config.remember_cookie]
        end

        def authenticate!
          token = env['rack.cookies'][Obscured::Doorman.config.remember_cookie]
          return unless token
          user = User.where({:confirm_token => token}).first
          env['rack.cookies'].delete(Obscured::Doorman.config.remember_cookie) and return if user.nil?
          success!(user)
        end
      end

      module RememberMe
        def self.registered(app)
          app.use Rack::Cookies

          Warden::Strategies.add(:remember_me, Doorman::Strategies::RememberMeStrategy)

          app.before do
            warden.authenticate(:remember_me)
          end

          Warden::Manager.after_authentication do |user, auth, opts|
            if auth.winning_strategy.is_a?(Doorman::Strategies::RememberMeStrategy) ||
                (auth.winning_strategy.is_a?(Doorman::Strategies::Password) &&
                    auth.params['user']['remember_me'])
              user.remember_me!  # new token
              auth.env['rack.cookies'][Obscured::Doorman.config.remember_cookie] = {
                  :value => user.remember_token,
                  :expires => Time.now + Obscured::Doorman.config.remember_for * 24 * 3600,
                  :path => '/' }
            end
          end

          Warden::Manager.before_logout do |user, auth, opts|
            user.forget_me! if user
            auth.env['rack.cookies'].delete(Obscured::Doorman.config.remember_cookie)
          end
        end
      end
    end
  end
end