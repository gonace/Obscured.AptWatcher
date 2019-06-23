module Obscured
  module Doorman
    module Strategies
      module ForgotPassword
        def self.registered(app)
          Warden::Manager.after_authentication do |user, auth, opts|
            # If the user requested a new password,
            # but then remembers and logs in,
            # then invalidate password reset token
            if auth.winning_strategy.is_a?(Obscured::Doorman::Strategies::Password)
              user.remembered_password!
            end
          end

          app.get '/doorman/forgot/?' do
            redirect Obscured::Doorman.config.paths[:success] if authenticated?

            email = cookies[:email]
            if email.nil?
              email = params[:email] rescue ''
            end

            haml :forgot, locals: { email: email }
          end

          app.post '/doorman/forgot' do
            redirect Obscured::Doorman.config.paths[:success] if authenticated?
            redirect '/' unless params['user']

            user = User.get_by_username(params['user']['email'])
            if user.nil?
              notify :error, :forgot_no_user
              redirect back
            end
            if user.role.to_sym == Obscured::Doorman::Roles::SYSTEM
              notify :error, :reset_system_user
              redirect Obscured::Doorman.config.paths[:forgot]
            end
            user.forget_password!

            template = haml :'/templates/password_reset',
                            layout: false,
                            locals: {
                              user: user.username,
                              link: token_link('reset', user)
                            }
            Pony.mail(
              to: user.username,
              from: "aptwatcher@#{Obscured::Doorman.config.smtp_domain}",
              subject: 'Password change request',
              body: "We have received a password change request for your account (#{user.username}). " + token_link('reset', user),
              html_body: template,
              via: :smtp,
              via_options: {
                address: Obscured::Doorman.config.smtp_server,
                port: Obscured::Doorman.config.smtp_port,
                enable_starttls_auto: true,
                user_name: Obscured::Doorman.config.smtp_username,
                password: Obscured::Doorman.config.smtp_password,
                authentication: :plain,
                domain: Obscured::Doorman.config.smtp_domain
              }
            )
            notify :success, :forgot_success
            redirect Obscured::Doorman.config.paths[:login]
          end

          app.get '/doorman/reset/:token/?' do
            redirect Obscured::Doorman.config.paths[:success] if authenticated?

            if params[:token].nil? || params[:token].empty?
              notify :error, :reset_no_token
              redirect '/'
            end

            user = User.where(confirm_token: params[:token]).first
            if user.nil?
              notify :error, :reset_no_user
              redirect Obscured::Doorman.config.paths[:login]
            end

            haml :reset, locals: {
              token: user.confirm_token,
              email: user.username
            }
          end

          app.post '/doorman/reset' do
            redirect Obscured::Doorman.config.paths[:success] if authenticated?
            redirect '/' unless params['user']

            user = User.where(confirm_token: params[:user][:token]).first
            if user.nil?
              notify :error, :reset_no_user
              redirect Obscured::Doorman.config.paths[:login]
            end
            if user.role.to_sym == Obscured::Doorman::Roles::SYSTEM
              notify :error, :reset_system_user
              redirect Obscured::Doorman.config.paths[:login]
            end

            success = user.reset_password!(params['user']['password'], params['user']['password_confirmation'])

            if success
              position = Geocoder.search(request.ip)
              template = haml :'/templates/password_confirmation', layout: false, locals: {
                user: user.username,
                browser: "#{request.browser} #{request.browser_version}",
                location: "#{position.first.city rescue ''},#{position.first.country rescue ''}",
                ip: request.ip,
                system: "#{request.os} #{request.os_version}"
              }

              Pony.mail(
                to: user.username,
                from: "aptwatcher@#{Obscured::Doorman.config.smtp_domain}",
                subject: 'Password change confirmation',
                body: "The password for your account (#{user.username}) was recently changed. This change was made from the following device or browser from: ",
                html_body: template,
                via: :smtp,
                via_options: {
                  address: Obscured::Doorman.config.smtp_server,
                  port: Obscured::Doorman.config.smtp_port,
                  enable_starttls_auto: true,
                  user_name: Obscured::Doorman.config.smtp_username,
                  password: Obscured::Doorman.config.smtp_password,
                  authentication: :plain,
                  domain: Obscured::Doorman.config.smtp_domain
                })
            else
              notify :error, :reset_unmatched_passwords
              redirect back
            end

            user.confirm_email!
            warden.set_user(user)
            notify :success, :reset_success
            redirect Obscured::Doorman.config.use_referrer && session[:return_to] ? session.delete(:return_to) : Obscured::Doorman.config.paths[:success]
          end
        end
      end
    end
  end
end