require 'sinatra/base'
require 'warden'
require 'pony'

module Obscured
  module Doorman
    class Warden::SessionSerializer
      def serialize(user); user.id; end
      def deserialize(id); User.get(id); end
    end

    ##
    # Base Features:
    #   * Signup with Email Confirmation
    #   * Login/Logout
    ##
    class PasswordStrategy < Warden::Strategies::Base
      def valid?
        params['user'] &&
          params['user']['login'] &&
          params['user']['password']
      end

      # Authenticate a user against defined strategies
      def authenticate!
        u = User.authenticate(params['user']['login'],params['user']['password'])

        if u.nil?
          fail!(Obscured::Doorman::Messages[:login_bad_credentials])
        elsif !u.confirmed
          fail!(Obscured::Doorman::Messages[:login_not_confirmed])
        else
          success!(u)
        end
      end
    end

    module Base
      module Helpers
        # The main accessor to the warden middleware
        def warden
          env['warden']
        end

        # Check the current session is authenticated to a given scope
        def authenticated?
          warden.authenticated?
        end
        alias_method :logged_in?, :authenticated?

        # Store the logged in user in the session
        #
        # @param [Object] user you want to store in the session
        # @option opts [Symbol] :scope The scope to assign the user
        # @example Set John as the current user
        #   user = User.find_by_name('John')
        def user=(user, opts={})
          warden.set_user(user, opts)
        end
        alias_method :current_user=, :user=

        # Generates a flash message by trying to fetch a default message, if that fails just pass the message
        def notify(type, message)
          message = message
          message = Obscured::Doorman::Messages[message] if message.is_a?(Symbol)
          flash[type] = message if defined?(Sinatra::Flash)
        end

        # Generates a url for confirm account or reset password
        def token_link(type, user)
          "http://#{env['HTTP_HOST']}/doorman/#{type}/#{user.confirm_token}"
        end
      end

      def self.registered(app)
        app.helpers Helpers
        app.use Warden::Manager do |manager|
          manager.scope_defaults :default,
            action: '/doorman/unauthenticated'

          manager.failure_app = lambda { |env|
            notify :error, Obscured::Doorman[:auth_required] if defined?(Sinatra::Flash)
            [302, { 'Location' => Obscured::Doorman.config.paths[:login] }, ['']]
          }
        end
        Warden::Manager.before_failure do |env,opts|
          # Because authentication failure can happen on any request but
          # we handle it only under "post '/doorman/unauthenticated'", we need
          # to change request to POST
          env['REQUEST_METHOD'] = 'POST'
          # And we need to do the following to work with  Rack::MethodOverride
          env.each do |key, value|
            env[key]['_method'] = 'post' if key == 'rack.request.form_hash'
          end
        end
        Warden::Strategies.add(:password, PasswordStrategy)

        app.get '/doorman/register/?' do
          redirect Obscured::Doorman.config.paths[:success] if authenticated?

          unless Obscured::Doorman.config.registration
            notify :error, :signup_disabled
            redirect Obscured::Doorman.config.paths[:login]
          end

          haml :register
        end

        app.post '/doorman/unauthenticated' do
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

          #redirect back
          redirect Obscured::Doorman.config.use_referrer && session[:return_to] ? session.delete(:return_to) : Obscured::Doorman.config.paths[:success]
        end

        app.get '/doorman/logout/?' do
          warden.logout(:default)
          notify :success, :logout_success

          redirect Obscured::Doorman.config.paths[:login]
        end
      end
    end


    ##
    # Remember Me Feature
    ##
    COOKIE_KEY = 'sinatra.doorman.remember'
    class RememberMeStrategy < Warden::Strategies::Base
      def valid?
        !!env['rack.cookies'][COOKIE_KEY]
      end

      def authenticate!
        token = env['rack.cookies'][COOKIE_KEY]
        return unless token
        user = User.where({:confirm_token => token}).first
        env['rack.cookies'].delete(COOKIE_KEY) and return if user.nil?
        success!(user)
      end
    end

    module RememberMe
      def self.registered(app)
        app.use Rack::Cookies

        Warden::Strategies.add(:remember_me, RememberMeStrategy)

        app.before do
          warden.authenticate(:remember_me)
        end

        Warden::Manager.after_authentication do |user, auth, opts|
          if auth.winning_strategy.is_a?(RememberMeStrategy) ||
            (auth.winning_strategy.is_a?(PasswordStrategy) &&
              auth.params['user']['remember_me'])
            user.remember_me!  # new token
            auth.env['rack.cookies'][COOKIE_KEY] = {
              :value => user.remember_token,
              :expires => Time.now + Obscured::Doorman.config.remember_for * 24 * 3600,
              :path => '/' }
          end
        end

        Warden::Manager.before_logout do |user, auth, opts|
          user.forget_me! if user
          auth.env['rack.cookies'].delete(COOKIE_KEY)
        end
      end
    end


    ##
    # Forgot Password Feature
    ##
    module ForgotPassword
      def self.registered(app)
        Warden::Manager.after_authentication do |user, auth, opts|
          # If the user requested a new password,
          # but then remembers and logs in,
          # then invalidate password reset token
          if auth.winning_strategy.is_a?(PasswordStrategy)
            user.remembered_password!
          end
        end

        app.get '/doorman/forgot/?' do
          redirect Obscured::Doorman.config.paths[:success] if authenticated?

          email = cookies[:email]
          if email.nil?
            email = params[:email] rescue ''
          end

          haml :forgot, :locals => {:email => email}
        end

        app.post '/doorman/forgot' do
          redirect Obscured::Doorman.config.paths[:success] if authenticated?
          redirect '/' unless params['user']

          user = User.get_by_username(params['user']['login'])
          if user.nil?
            notify :error, :forgot_no_user
            redirect back
          end
          if user.role.to_sym == Obscured::Doorman::Roles::SYSTEM
            notify :error, :reset_system_user
            redirect Obscured::Doorman.config.paths[:forgot]
          end

          user.forgot_password!
          Pony.mail(
            :to => user.username,
            :from => "aptwatcher@#{Obscured::Doorman.config.smtp_domain}",
            :subject => 'Password change request',
            :body => "We have received a password change request for your account (#{user.username}). " + token_link('reset', user),
            :html_body => (haml :'/templates/password_reset', :locals => {:user => user.username, :link => token_link('reset', user)}, :layout => false),
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
          notify :success, :forgot_success
          redirect Obscured::Doorman.config.paths[:login]
        end

        app.get '/doorman/reset/:token/?' do
          redirect Obscured::Doorman.config.paths[:success] if authenticated?

          if params[:token].nil? || params[:token].empty?
            notify :error, :reset_no_token
            redirect '/'
          end

          user = User.where({:confirm_token => params[:token]}).first
          if user.nil?
            notify :error, :reset_no_user
            redirect Obscured::Doorman.config.paths[:login]
          end

          haml :reset, :locals => { :confirm_token => user.confirm_token, :email => user.username }
        end

        app.post '/doorman/reset' do
          redirect Obscured::Doorman.config.paths[:success] if authenticated?
          redirect '/' unless params['user']

          user = User.where({:confirm_token => params[:user][:confirm_token]}).first rescue nil
          if user.nil?
            notify :error, :reset_no_user
            redirect Obscured::Doorman.config.paths[:login]
          end
          if user.role.to_sym == Obscured::Doorman::Roles::SYSTEM
            notify :error, :reset_system_user
            redirect Obscured::Doorman.config.paths[:login]
          end

          success = user.reset_password!(
            params['user']['password'],
            params['user']['password_confirmation'])

          unless success
            notify :error, :reset_unmatched_passwords
            redirect back
          else
            geo_position = Geocoder.search(request.ip)
            Pony.mail(
              :to => user.username,
              :from => "aptwatcher@#{Obscured::Doorman.config.smtp_domain}",
              :subject => 'Password change confirmation',
              :body => "The password for your account (#{user.username}) was recently changed. This change was made from the following device or browser from: ",
              :html_body => (haml :'/templates/password_confirmation', :locals => {:user => user.username, :browser => "#{request.browser} #{request.browser_version}", :location => "#{geo_position.first.city rescue ''},#{geo_position.first.country rescue ''}", :ip => request.ip, :system => "#{request.os} #{request.os_version}"}, :layout => false),
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
          end

          user.confirm_email!
          warden.set_user(user)
          notify :success, :reset_success
          redirect Obscured::Doorman.config.use_referrer && session[:return_to] ? session.delete(:return_to) : Obscured::Doorman.config.paths[:success]
        end
      end
    end

    class Middleware < Sinatra::Base
      register Sinatra::Flash
      register Sinatra::Partial
      register Base
      register RememberMe
      register ForgotPassword
      helpers Sinatra::Cookies
      use Rack::UserAgent
    end
  end
end