module Obscured
  module AptWatcher
    module Controllers
      class Settings < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/settings'


        get '/' do
          authorize!

          haml :index, :locals => { :config => configuration }
        end


        post '/enable/registration', '/disable/registration' do
          authenticated?
          content_type :json

          begin
            enabled = params[:enabled]
            config = configuration

            if enabled == 'true'
              config.user_registration = true
            else
              config.user_registration = false
            end
            config.save

            Obscured::AptWatcher::Entities::Ajax::Response.new({:enabled => enabled}).to_json
          rescue Exception => e
            Obscured::AptWatcher::Entities::Ajax::Error.new(e.message, e.class.name, false).to_json
          end
        end

        post '/enable/confirmation', '/disable/confirmation' do
          authenticated?
          content_type :json

          begin
            enabled = params[:enabled]
            config = configuration

            if enabled == 'true'
              config.user_confirmation = true
            else
              config.user_confirmation = false
            end
            config.save

            Obscured::AptWatcher::Entities::Ajax::Response.new({:enabled => enabled}).to_json
          rescue Exception => e
            Obscured::AptWatcher::Entities::Ajax::Error.new(e.message, e.class.name, false).to_json
          end
        end

        post '/enable/raygun', '/disable/raygun' do
          authenticated?
          content_type :json

          begin
            enabled = params[:enabled]
            config = configuration

            if enabled == 'true'
              config.raygun_enabled = true
            else
              config.raygun_enabled = false
            end
            config.save

            Obscured::AptWatcher::Entities::Ajax::Response.new({:enabled => enabled}).to_json
          rescue Exception => e
            Obscured::AptWatcher::Entities::Ajax::Error.new(e.message, e.class.name, false).to_json
          end
        end

        post '/enable/mail', '/disable/mail' do
          authenticated?
          content_type :json

          begin
            enabled = params[:enabled]
            config = configuration

            if enabled == 'true'
              config.smtp_enabled = true
            else
              config.smtp_enabled = false
            end
            config.save

            Obscured::AptWatcher::Entities::Ajax::Response.new({:enabled => enabled}).to_json
          rescue Exception => e
            Obscured::AptWatcher::Entities::Ajax::Error.new(e.message, e.class.name, false).to_json
          end
        end

        post '/enable/slack', '/disable/slack' do
          authenticated?
          content_type :json

          begin
            enabled = params[:enabled]
            config = configuration

            if enabled == 'true'
              config.slack_enabled = true
            else
              config.slack_enabled = false
            end
            config.save

            Obscured::AptWatcher::Entities::Ajax::Response.new({:enabled => enabled}).to_json
          rescue Exception => e
            Obscured::AptWatcher::Entities::Ajax::Error.new(e.message, e.class.name, false).to_json
          end
        end

        post '/enable/bitbucket', '/disable/bitbucket' do
          authenticated?
          content_type :json

          begin
            enabled = params[:enabled]
            config = configuration

            if enabled == 'true'
              config.bitbucket_enabled = true
            else
              config.bitbucket_enabled = false
            end
            config.save

            Obscured::AptWatcher::Entities::Ajax::Response.new({:enabled => enabled}).to_json
          rescue Exception => e
            Obscured::AptWatcher::Entities::Ajax::Error.new(e.message, e.class.name, false).to_json
          end
        end

        post '/enable/github', '/disable/github' do
          authenticated?
          content_type :json

          begin
            enabled = params[:enabled]
            config = configuration

            if enabled == 'true'
              config.github_enabled = true
            else
              config.github_enabled = false
            end
            config.save

            Obscured::AptWatcher::Entities::Ajax::Response.new({:enabled => enabled}).to_json
          rescue Exception => e
            Obscured::AptWatcher::Entities::Ajax::Error.new(e.message, e.class.name, false).to_json
          end
        end


        post '/api/update' do
          authenticated?
          raise ArgumentError, 'No api_username provided' unless params[:api_username]
          raise ArgumentError, 'No api_password provided' unless params[:api_password]

          config = configuration
          config.api_username = params[:api_username]
          config.api_password = params[:api_password]
          config.save

          redirect '/settings'
        end

        post '/raygun/update' do
          authenticated?
          raise ArgumentError, 'No raygun_key provided' unless params[:raygun_key]

          config = configuration
          config.raygun_key = params[:raygun_key]
          config.save

          redirect '/settings'
        end

        post '/slack/update' do
          authenticated?
          raise ArgumentError, 'No slack_channel provided' unless params[:slack_channel]
          raise ArgumentError, 'No slack_user provided' unless params[:slack_user]
          raise ArgumentError, 'No slack_icon provided' unless params[:slack_icon]
          raise ArgumentError, 'No slack_webhook provided' unless params[:slack_webhook]

          config = configuration
          config.slack_channel = params[:slack_channel]
          config.slack_user = params[:slack_user]
          config.slack_icon = params[:slack_icon]
          config.slack_webhook = params[:slack_webhook]
          config.save

          redirect '/settings'
        end

        post '/mail/update' do
          authenticated?
          raise ArgumentError, 'No smtp_domain provided' unless params[:smtp_domain]
          raise ArgumentError, 'No smtp_username provided' unless params[:smtp_username]
          raise ArgumentError, 'No smtp_password provided' unless params[:smtp_password]
          raise ArgumentError, 'No smtp_host provided' unless params[:smtp_host]
          raise ArgumentError, 'No smtp_port provided' unless params[:smtp_port]

          config = configuration
          config.smtp_domain = params[:smtp_domain]
          config.smtp_username = params[:smtp_username]
          config.smtp_password = params[:smtp_password]
          config.smtp_host = params[:smtp_host]
          config.smtp_port = params[:smtp_port]
          config.save

          redirect '/settings'
        end

        post '/bitbucket/update' do
          authenticated?
          raise ArgumentError, 'No bitbucket_key provided' unless params[:bitbucket_key]
          raise ArgumentError, 'No bitbucket_secret provided' unless params[:bitbucket_secret]

          config = configuration
          config.bitbucket_key = params[:bitbucket_key]
          config.bitbucket_secret = params[:bitbucket_secret]
          config.save

          redirect '/settings'
        end

        post '/github/update' do
          authenticated?
          raise ArgumentError, 'No github_key provided' unless params[:github_key]
          raise ArgumentError, 'No github_secret provided' unless params[:github_secret]

          config = configuration
          config.github_key = params[:github_key]
          config.github_secret = params[:github_secret]
          config.save

          redirect '/settings'
        end
      end
    end
  end
end