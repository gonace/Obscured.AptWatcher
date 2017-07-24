require 'sinatra/base'
require 'rest-client'
require File.expand_path('../bitbucket/messages', __FILE__)
require File.expand_path('../bitbucket/access_token', __FILE__)
require File.expand_path('../bitbucket/strategy', __FILE__)


module Obscured
  module Doorman
    module Providers
      module Bitbucket
        ##
        # Configuration options should be set by passing a hash:
        #
        #   Obscured::Doorman::Providers::Bitbucket.configure(
        #     :client_id       => 'xxx',
        #     :client_secret   => 'xxx',
        #     :base_url        => 'https://aptwatcher.herokuapp.com',
        #     :scopes          => 'account'
        #   )
        #
        def self.configure(options = nil, &block)
          if !options.nil?
            Configuration.instance.configure(options)
          end
        end

        ##
        # Read-only access to the singleton's config data.
        #
        def self.config
          Configuration.instance.data
        end

        class Configuration
          include Singleton

          OPTIONS = [
            :provider,
            :client_id,
            :client_secret,
            :authorize_url,
            :token_url,
            :login_url,
            :redirect_url,
            :scopes,
            :valid_domains,
            :token
          ]

          attr_accessor :data

          def self.set_defaults
            instance.set_defaults
          end

          OPTIONS.each do |o|
            define_method o do
              @data[o]
            end
            define_method "#{o}=" do |value|
              @data[o] = value
            end
          end

          def configure(options)
            @data.rmerge!(options)
          end

          def initialize # :nodoc
            @data = Bitbucket::ConfigurationHash.new
            set_defaults
          end

          def set_defaults
            @data[:provider]           = Obscured::Doorman::Providers::Bitbucket          # Provider name
            @data[:client_id]          = nil                                              # Bitbucket consumer key
            @data[:client_secret]      = nil                                              # Bitbucket consumer secret
            @data[:authorize_url]      = 'https://bitbucket.org/site/oauth2/authorize'    # Bitbucket Authorize URL
            @data[:token_url]          = 'https://bitbucket.org/site/oauth2/access_token' # Bitbucket Token URL
            @data[:login_url]          = '/doorman/oauth2/bitbucket'                      # Login url
            @data[:redirect_url]       = '/doorman/oauth2/bitbucket/callback'             # Redirect url
            @data[:valid_domains]      = nil                                              # Domain that should be accepted (nil = accept all email domains), also
                                                                                          # accepting comma separated string to support multiple domains validation.
            @data[:scopes]             = 'account'                                        # Bitbucket scopes
            @data[:token]              = nil
          end

          instance_eval(OPTIONS.map do |option|
            o = option.to_s
            <<-EOS
              def #{o}
                instance.data[:#{o}]
              end
        
              def #{o}=(value)
                instance.data[:#{o}] = value
              end
            EOS
          end.join("\n\n"))
        end

        class ConfigurationHash < Hash
          include HashRecursiveMerge

          def method_missing(meth, *args, &block)
            has_key?(meth) ? self[meth] : super
          end
        end

        module Helpers
          # Generates a flash message by trying to fetch a default message, if that fails just pass the message
          def notify(type, message)
            message = Messages[message] if message.is_a?(Symbol)
            flash[type] = message if defined?(Sinatra::Flash)
          end
        end


        def self.registered(app)
          app.helpers Doorman::Base::Helpers

          # Enable Sessions
          unless defined?(Rack::Session::Cookie)
            app.set :sessions, true
          end

          app.use Warden::Manager do |config|
            config.strategies.add :bitbucket, Bitbucket::Strategy
          end

          app.get '/doorman/oauth2/bitbucket' do
            redirect "#{Bitbucket.config[:authorize_url]}?client_id=#{Bitbucket.config[:client_id]}&response_type=code&scopes=#{GitHub.config[:scopes]}"
          end

          app.get '/doorman/oauth2/bitbucket/callback/?' do
            begin
              response = RestClient::Request.new(
                :method => :post,
                :url => Bitbucket.config[:token_url],
                :user => Bitbucket.config[:client_id],
                :password => Bitbucket.config[:client_secret],
                :payload => "code=#{params[:code]}&grant_type=authorization_code"
              ).execute

              json = JSON.parse(response.body)
              token = Bitbucket::AccessToken.new(access_token: json['access_token'],
                                                 refresh_token: json['refresh_token'],
                                                 scopes: json['scopes'],
                                                 expires_in: json['expires_in'])

              emails = RestClient.get 'https://api.bitbucket.org/2.0/user/emails',{ 'Authorization' => "Bearer #{token.access_token}" }
              emails = JSON.parse(emails.body)
              token.emails = emails.values[1].map { |e| e['email'] }

              Bitbucket.config[:token] = token
            rescue RestClient::ExceptionWithResponse => e
              message = JSON.parse(e.response)
              notify :error, "#{message['error_description']} (#{message['error']})"
              redirect '/doorman/login'
            end

            warden.authenticate(:bitbucket)

            # Notify if there are any messages from Warden.
            unless warden.message.blank?
              notify :error, warden.message
            end

            #redirect back
            redirect Obscured::Doorman.config.use_referrer && session[:return_to] ? session.delete(:return_to) : Obscured::Doorman.config.paths[:success]
          end
        end
      end
    end
  end
end