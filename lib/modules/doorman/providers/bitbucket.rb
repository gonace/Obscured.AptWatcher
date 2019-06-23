require 'sinatra/base'
require 'rest-client'
require File.expand_path('bitbucket/messages', __dir__)
require File.expand_path('bitbucket/access_token', __dir__)
require File.expand_path('bitbucket/strategy', __dir__)

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
        def self.configure(options = nil, &_block)
          Configuration.instance.configure(options) unless options.nil?
        end

        ##
        # Read-only access to the singleton's config data.
        #
        def self.config
          Configuration.instance.data
        end

        class Configuration
          include Singleton

          OPTIONS = %i[
            provider
            client_id
            client_secret
            authorize_url
            token_url
            login_url
            redirect_url
            scopes
            domains
            token
          ].freeze

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

          def initialize
            @data = Doorman::ConfigurationHash.new
            set_defaults
          end

          def set_defaults
            @data[:provider]           = Obscured::Doorman::Providers::Bitbucket
            @data[:client_id]          = nil
            @data[:client_secret]      = nil
            @data[:authorize_url]      = 'https://bitbucket.org/site/oauth2/authorize'
            @data[:token_url]          = 'https://bitbucket.org/site/oauth2/access_token'
            @data[:login_url]          = '/doorman/oauth2/bitbucket'
            @data[:redirect_url]       = '/doorman/oauth2/bitbucket/callback'
            @data[:domains]            = nil
            @data[:scopes]             = 'account'
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

        def self.registered(app)
          app.helpers Doorman::Base::PrivateHelpers
          app.helpers Doorman::Helpers

          Warden::Strategies.add(:bitbucket, Bitbucket::Strategy)

          app.get '/doorman/oauth2/bitbucket' do
            redirect "#{Bitbucket.config[:authorize_url]}?client_id=#{Bitbucket.config[:client_id]}&response_type=code&scopes=#{Bitbucket.config[:scopes]}"
          end

          app.get '/doorman/oauth2/bitbucket/callback/?' do
            response = RestClient::Request.new(
              method: :post,
              url: Bitbucket.config[:token_url],
              user: Bitbucket.config[:client_id],
              password: Bitbucket.config[:client_secret],
              payload: "code=#{params[:code]}&grant_type=authorization_code&scope=#{Bitbucket.config[:scopes]}",
              headers: {Accept: 'application/json'}
            ).execute

            json = JSON.parse(response.body)
            token = Bitbucket::AccessToken.new(
              access_token: json['access_token'],
              refresh_token: json['refresh_token'],
              scopes: json['scopes'],
              expires_in: json['expires_in']
            )

            emails = RestClient.get 'https://api.bitbucket.org/2.0/user/emails',{ 'Authorization' => "Bearer #{token.access_token}" }
            emails = JSON.parse(emails.body)
            token.emails = emails.values[1].map { |e| e['email'] }
            Bitbucket.config[:token] = token

            # Authenticate with :bitbucket strategy
            warden.authenticate(:bitbucket)
          rescue RestClient::ExceptionWithResponse => e
            message = JSON.parse(e.response)
            notify :error, "#{message['error_description']} (#{message['error']})"
            redirect '/doorman/login'
          ensure
            # Notify if there are any messages from Warden.
            notify :error, warden.message unless warden.message.blank?
            redirect Obscured::Doorman.config.use_referrer && session[:return_to] ? session.delete(:return_to) : Obscured::Doorman.config.paths[:success]
          end
        end
      end
    end
  end
end