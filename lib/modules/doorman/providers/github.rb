require 'sinatra/base'
require 'rest-client'
require File.expand_path('github/messages', __dir__)
require File.expand_path('github/access_token', __dir__)
require File.expand_path('github/strategy', __dir__)

module Obscured
  module Doorman
    module Providers
      module GitHub
        ##
        # Configuration options should be set by passing a hash:
        #
        #   Obscured::Doorman::Providers::GitHub.configure(
        #     :client_id       => 'xxx',
        #     :client_secret   => 'xxx',
        #     :base_url        => 'https://aptwatcher.herokuapp.com',
        #     :scopes          => 'user:email'
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
            @data[:provider]           = Obscured::Doorman::Providers::GitHub
            @data[:client_id]          = nil
            @data[:client_secret]      = nil
            @data[:authorize_url]      = 'https://github.com/login/oauth/authorize'
            @data[:token_url]          = 'https://github.com/login/oauth/access_token'
            @data[:login_url]          = '/doorman/oauth2/github'
            @data[:redirect_uri]       = '/doorman/oauth2/github/callback'
            @data[:domains]            = nil
            @data[:scopes]             = 'user:email'
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

          Warden::Strategies.add(:github, GitHub::Strategy)

          app.get '/doorman/oauth2/github' do
            redirect "#{GitHub.config[:authorize_url]}?client_id=#{GitHub.config[:client_id]}&response_type=code&scope=#{GitHub.config[:scopes]}"
          end

          app.get '/doorman/oauth2/github/callback/?' do
            response = RestClient::Request.new(
              method: :post,
              url: GitHub.config[:token_url],
              user: GitHub.config[:client_id],
              password: GitHub.config[:client_secret],
              payload: "code=#{params[:code]}&grant_type=authorization_code&scope=#{GitHub.config[:scopes]}",
              headers: { Accept: 'application/json' }
            ).execute

            json = JSON.parse(response.body)
            token = GitHub::AccessToken.new(
              access_token: json['access_token'],
              token_type: json['token_type'],
              scope: json['scope']
            )

            emails = RestClient.get 'https://api.github.com/user/emails',
                                    'Authorization' => "token #{token.access_token}"
            emails = JSON.parse(emails.body)
            token.emails = emails.map { |e| e['email'] }
            GitHub.config[:token] = token

            # Authenticate with :github strategy
            warden.authenticate(:github)
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