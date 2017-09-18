require 'sinatra/base'
require 'warden'
require 'pony'

module Obscured
  module Doorman
    class Warden::SessionSerializer
      def serialize(user); user.id; end
      def deserialize(id); User.get(id); end
    end


    module Base
      module Helpers
        # Generates a flash message by trying to fetch a default message, if that fails just pass the message
        def notify(type, message)
          message = Obscured::Doorman::Messages[message] if message.is_a?(Symbol)
          flash[type] = message if defined?(Sinatra::Flash)
        end

        # Generates a url for confirm account or reset password
        def token_link(type, user)
          "http://#{env['HTTP_HOST']}/doorman/#{type}/#{user.confirm_token}"
        end
      end

      def self.registered(app)
        app.helpers Doorman::Base::Helpers
        app.helpers Doorman::Helpers

        # Enable Sessions
        unless defined?(Rack::Session::Cookie)
          app.set :sessions, true
        end

        app.use Warden::Manager do |config|
          config.scope_defaults :default,
            action: '/doorman/unauthenticated'

          config.failure_app = lambda { |_env|
            notify :error, Obscured::Doorman[:auth_required] if defined?(Sinatra::Flash)
            [302, { 'Location' => Obscured::Doorman.config.paths[:login] }, ['']]
          }
        end

        Warden::Manager.before_failure do |env, _opts|
          # Because authentication failure can happen on any request but
          # we handle it only under "post '/doorman/unauthenticated'", we need
          # to change request to POST
          env['REQUEST_METHOD'] = 'POST'
          # And we need to do the following to work with  Rack::MethodOverride
          env.each do |key, _value|
            env[key]['_method'] = 'post' if key == 'rack.request.form_hash'
          end
        end
        Warden::Strategies.add(:password, Doorman::Strategies::Password)

        app.get '/doorman/register/?' do
          redirect Obscured::Doorman.config.paths[:success] if authenticated?

          unless Obscured::Doorman.config.registration
            notify :error, :signup_disabled
            redirect Obscured::Doorman.config.paths[:login]
          end

          haml :register
        end

        app.post '/doorman/unauthenticated' do
          status 401
          session[:return_to] = env['warden.options'][:attempted_path] if session[:return_to].nil?
          redirect Obscured::Doorman.config.paths[:login]
        end

        app.post '/doorman/register' do
          redirect Obscured::Doorman.config.paths[:success] if authenticated?

          unless Obscured::Doorman.config.registration
            notify :error, :signup_disabled
            redirect Obscured::Doorman.config.paths[:login]
          end

          begin
            user = User.make({:username => params[:user][:login], :password => params[:user][:password], :confirmed => !Obscured::Doorman.config.confirmation})
            user.set_name(params[:user][:first_name], params[:user][:last_name])
            user.save
          rescue => e
            notify :error, e.message
            redirect back
          end

          notify :success, :signup_success
          Pony.mail(
            :to => user.username,
            :from => "aptwatcher@#{Obscured::Doorman.config.smtp_domain}",
            :subject => 'Account activation request',
            :body => "You have to activate your account (#{user.username}) before using this service. " + token_link('confirm', user),
            :html_body => (haml :'/templates/account_activation', :locals => {:user => user.username, :link => token_link('confirm', user)}, :layout => false),
            :via => :smtp,
            :via_options => {
              :address        	    => Obscured::Doorman.config.smtp_server,
              :port          	  	  => Obscured::Doorman.config.smtp_port,
              :enable_starttls_auto => true,
              :user_name         	  => Obscured::Doorman.config.smtp_username,
              :password          	  => Obscured::Doorman.config.smtp_password,
              :authentication 	    => :plain,
              :domain           	  => Obscured::Doorman.config.smtp_domain
          })

          redirect "/doorman/login?email=#{user.username}"
        end

        app.get '/doorman/confirm/:token/?' do
          redirect Obscured::Doorman.config.paths[:success] if authenticated?

          if params[:token].nil? || params[:token].empty?
            notify :error, :confirm_no_token
            redirect '/'
          end

          user = User.where({:confirm_token => params[:token]}).first
          if user.nil?
            notify :error, :confirm_no_user
          else
            user.confirm_email!
            notify :success, :confirm_success
          end
          redirect Obscured::Doorman.config.paths[:login]
        end

        app.get '/doorman/login/?' do
          redirect Obscured::Doorman.config.paths[:success] if authenticated?

          email = cookies[:email]
          if email.nil?
            email = params[:email] rescue ''
          end

          haml :login, locals: {:email => email}
        end

        app.post '/doorman/login' do
          warden.authenticate(:password)

          # Set cookie
          cookies[:email] = params['user']['login']

          # Notify if there are any messages from Warden.
          unless warden.message.blank?
            notify :error, warden.message
          end

          redirect(Obscured::Doorman.config.use_referrer && session[:return_to] ? session.delete(:return_to) : Obscured::Doorman.config.paths[:success])
        end

        app.get '/doorman/logout/?' do
          warden.logout(:default)
          notify :success, :logout_success

          redirect Obscured::Doorman.config.paths[:login]
        end
      end
    end


    class Middleware < Sinatra::Base
      helpers Sinatra::Configuration
      helpers Sinatra::Cookies
      register Sinatra::Flash
      register Sinatra::Partial
      register Strategies::RememberMe
      register Strategies::ForgotPassword
      register Doorman::Base
      register Doorman::Providers::Bitbucket
      register Doorman::Providers::GitHub
      use Rack::UserAgent
    end
  end
end