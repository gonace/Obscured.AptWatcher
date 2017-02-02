require 'sinatra/base'
require 'warden'
require 'pony'

module Sinatra
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

      def authenticate!
        user = User.authenticate(params['user']['login'],params['user']['password'])

        if user.nil?
          fail!(:login_bad_credentials)
        elsif !user.confirmed
          fail!(:login_not_confirmed)
        else
          success!(user)
        end
      end
    end

    module Base
      module Helpers
        def authenticated?
          env['warden'].authenticated?
        end
        alias_method :logged_in?, :authenticated?

        def notify(type, message)
          message = Messages[message] if message.is_a?(Symbol)
          flash[type] = message if defined?(Sinatra::Flash)
        end

        def token_link(type, user)
          "http://#{env['HTTP_HOST']}/doorman/#{type}/#{user.confirm_token}"
        end
      end

      def self.registered(app)
        app.helpers Helpers
        app.use Warden::Manager do |manager|
          manager.scope_defaults :default,
            action: 'auth/unauthenticated'

          manager.failure_app = lambda { |env|
            env['x-rack.flash'][:error] = Messages[:auth_required] if defined?(Sinatra::Flash)
            [302, { 'Location' => '/doorman/login' }, ['']]
          }
        end
        Warden::Manager.before_failure do |env,opts|
          # Because authentication failure can happen on any request but
          # we handle it only under "post '/auth/unauthenticated'", we need
          # to change request to POST
          env['REQUEST_METHOD'] = 'POST'
          # And we need to do the following to work with  Rack::MethodOverride
          env.each do |key, value|
            env[key]['_method'] = 'post' if key == 'rack.request.form_hash'
          end
        end
        Warden::Strategies.add(:password, PasswordStrategy)

        app.get '/doorman/register/?' do
          ###
          # Registration disabled
          ###
          #redirect '/organisations' if authenticated?
          #haml :register

          notify :error, 'Registration is disabled, contact team member for creation of account!'
          redirect '/doorman/login'
        end

        app.post '/doorman/unauthenticated' do
          session[:return_to] = env['warden.options'][:attempted_path] if session[:return_to].nil?
          redirect '/auth/login'
        end

        app.post '/doorman/register' do
          ###
          # Registration disabled
          ###
          notify :error, 'Registration is disabled, contact team member for creation of account!'
          redirect '/doorman/login'

          redirect '/home' if authenticated?

          user = User.make(params[:utils])

          unless user.save
            notify :error, user.errors.first
            redirect back
          end

          notify :success, :signup_success
          notify :success, 'Signed up: ' + user.confirm_token
          Pony.mail(
            :to => user.username,
            :from => "aptwatcher@#{@smtp_domain}",
            :subject => 'Account activation request',
            :body => "You have to activate your account (#{user.username}) before using this service. " + token_link('confirm', user),
            :html_body => '',
            :via => :smtp,
            :via_options => {
              :address        	    => @smtp_server,
              :port          	  	  => @smtp_port,
              :enable_starttls_auto => true,
              :user_name         	  => @smtp_username,
              :password          	  => @smtp_password,
              :authentication 	    => :plain,
              :domain           	  => @smtp_domain
          })

          redirect '/'
        end

        app.get '/doorman/confirm/:token/?' do
          redirect '/home' if authenticated?

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
          redirect '/doorman/login'
        end

        app.get '/doorman/login/?' do
          redirect '/home' if authenticated?
          haml :login, locals: {:email => ''}
        end

        app.post '/doorman/login' do
          env['warden'].authenticate(:password)
          redirect back
        end

        app.get '/doorman/logout/?' do
          env['warden'].logout(:default)
          notify :success, :logout_success
          redirect '/doorman/login'
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
          env['warden'].authenticate(:remember_me)
        end

        Warden::Manager.after_authentication do |user, auth, opts|
          if auth.winning_strategy.is_a?(RememberMeStrategy) ||
            (auth.winning_strategy.is_a?(PasswordStrategy) &&
              auth.params['user']['remember_me'])
            user.remember_me!  # new token
            auth.env['rack.cookies'][COOKIE_KEY] = {
              :value => user.remember_token,
              :expires => Time.now + 7 * 24 * 3600,
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
          redirect '/home' if authenticated?
          haml :forgot, :locals => {:email => ''}
        end

        app.post '/doorman/forgot' do
          redirect '/home' if authenticated?
          redirect '/' unless params['user']

          user = User.get_by_username(params['user']['login'])
          if user.nil?
            notify :error, :forgot_no_user
            redirect back
          end
          if user.role.to_sym == Sinatra::Doorman::Utils::Roles::SYSTEM
            notify :error, :reset_system_user
            redirect '/doorman/forgot'
          end

          user.forgot_password!
          Pony.mail(
            :to => user.username,
            :from => "aptwatcher@#{@smtp_domain}",
            :subject => 'Password change request',
            :body => "We have received a password change request for your account (#{user.username}). " + token_link('reset', user),
            :html_body => (haml :'/templates/password_reset', :locals => {:user => user.username, :link => token_link('reset', user)}, :layout => false),
            :via => :smtp,
            :via_options => {
              :address        	    => @smtp_server,
              :port          	  	  => @smtp_port,
              :enable_starttls_auto => true,
              :user_name         	  => @smtp_username,
              :password          	  => @smtp_password,
              :authentication 	    => :plain,
              :domain           	  => @smtp_domain
            })
          notify :success, :forgot_success
          redirect '/doorman/login'
        end

        app.get '/doorman/reset/:token/?' do
          redirect '/home' if authenticated?

          if params[:token].nil? || params[:token].empty?
            notify :error, :reset_no_token
            redirect '/'
          end

          user = User.where({:confirm_token => params[:token]}).first
          if user.nil?
            notify :error, :reset_no_user
            redirect '/doorman/login'
          end

          haml :reset, :locals => { :confirm_token => user.confirm_token, :email => user.username }
        end

        app.post '/doorman/reset' do
          redirect '/home' if authenticated?
          redirect '/' unless params['user']

          user = User.where({:confirm_token => params[:user][:confirm_token]}).first rescue nil
          if user.nil?
            notify :error, :reset_no_user
            redirect '/doorman/login'
          end
          if user.role.to_sym == Sinatra::Doorman::Utils::Roles::SYSTEM
            notify :error, :reset_system_user
            redirect '/doorman/login'
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
              :from => "aptwatcher@#{@smtp_domain}",
              :subject => 'Password change confirmation',
              :body => "The password for your account (#{user.username}) was recently changed. This change was made from the following device or browser from: ",
              :html_body => (haml :'/templates/password_confirmation', :locals => {:user => user.username, :browser => "#{request.browser} #{request.browser_version}", :location => "#{geo_position.city},#{geo_position.region_name}", :ip => request.ip, :system => "#{request.os} #{request.os_version}"}, :layout => false),
              :via => :smtp,
              :via_options => {
                :address        	    => @smtp_server,
                :port          	  	  => @smtp_port,
                :enable_starttls_auto => true,
                :user_name         	  => @smtp_username,
                :password          	  => @smtp_password,
                :authentication 	    => :plain,
                :domain           	  => @smtp_domain
              })
          end

          user.confirm_email!
          env['warden'].set_user(user)
          notify :success, :reset_success
          redirect '/home'
        end
      end
    end

    class Middleware < Sinatra::Base
      register Sinatra::Flash
      register Sinatra::Partial
      register Base
      register RememberMe
      register ForgotPassword
      use Rack::UserAgent


      def initialize(app, args)
        super app
        @args = args

        raise ArgumentError, 'A SMTP domain must be provided' if args[:smtp_domain].nil?
        raise ArgumentError, 'A SMTP username must be provided' if args[:smtp_username].nil?
        raise ArgumentError, 'A SMTP password must be provided' if args[:smtp_password].nil?


        @smtp_server = args[:smtp_server] rescue 'smtp.sendgrid.net'
        @smtp_port = args[:smtp_port] rescue '587'
        @smtp_domain = args[:smtp_domain]
        @smtp_username = args[:smtp_username]
        @smtp_password = args[:smtp_password]
      end
    end
  end
end