# frozen_string_literal: true

module Obscured
  module AptWatcher
    module Controllers
      class Settings < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/settings'


        get '/' do
          authorize!

          haml :index, locals: { config: configuration }
        end

        get '/authentication' do
          authorize!

          begin

            haml :authentication, locals: {
            }
          rescue => e
            Obscured::AptWatcher::Models::Error.make!(notifier: Obscured::Alert::Type::SYSTEM, message: e.message, backtrace: e.backtrace.join('<br />'))
            flash[:error] = e.message
            redirect '/'
          end
        end

        get '/managers' do
          authorize!

          begin
            managers = Obscured::AptWatcher::Managers.all.sort_by(&:signature)

            haml :managers, locals: {
              managers: managers
            }
          rescue => e
            Obscured::AptWatcher::Models::Error.make!(notifier: Obscured::Alert::Type::SYSTEM, message: e.message, backtrace: e.backtrace.join('<br />'))
            flash[:error] = e.message
            redirect '/'
          end
        end

        get '/plugins' do
          authorize!

          begin
            plugins = Obscured::AptWatcher::Plugins.all.sort_by(&:signature)

            haml :plugins, locals: {
              plugins: plugins
            }
          rescue => e
            Obscured::AptWatcher::Models::Error.make!(notifier: Obscured::Alert::Type::SYSTEM, message: e.message, backtrace: e.backtrace.join('<br />'))
            flash[:error] = e.message
            redirect '/'
          end
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

            Obscured::AptWatcher::Entities::Ajax::Response.new(enabled: enabled).to_json
          rescue StandardError => e
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

            Obscured::AptWatcher::Entities::Ajax::Response.new(enabled: enabled).to_json
          rescue StandardError => e
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
              config.raygun.enabled = true
            else
              config.raygun.enabled = false
            end
            config.save

            Obscured::AptWatcher::Entities::Ajax::Response.new(enabled: enabled).to_json
          rescue StandarError => e
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
              config.smtp.enabled = true
            else
              config.smtp.enabled = false
            end
            config.save

            Obscured::AptWatcher::Entities::Ajax::Response.new(enabled: enabled).to_json
          rescue StandardError => e
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
              config.slack.enabled = true
            else
              config.slack.enabled = false
            end
            config.save

            Obscured::AptWatcher::Entities::Ajax::Response.new(enabled: enabled).to_json
          rescue StandardError => e
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
              config.bitbucket.enabled = true
            else
              config.bitbucket.enabled = false
            end
            config.save

            Obscured::AptWatcher::Entities::Ajax::Response.new(enabled: enabled).to_json
          rescue StandardError => e
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
              config.github.enabled = true
            else
              config.github.enabled = false
            end
            config.save

            Obscured::AptWatcher::Entities::Ajax::Response.new(enabled: enabled).to_json
          rescue StandardError => e
            Obscured::AptWatcher::Entities::Ajax::Error.new(e.message, e.class.name, false).to_json
          end
        end


        post '/api/update' do
          authenticated?
          raise ArgumentError, 'No api_username provided' unless params[:api_username]
          raise ArgumentError, 'No api_password provided' unless params[:api_password]

          config = configuration
          config.api.username = params[:api_username]
          config.api.password = params[:api_password]
          config.save

          redirect '/settings'
        end

        post '/raygun/update' do
          authenticated?
          raise ArgumentError, 'No raygun_key provided' unless params[:raygun_key]

          config = configuration
          config.raygun.key = params[:raygun_key]
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
          config.slack.channel = params[:slack_channel]
          config.slack.user = params[:slack_user]
          config.slack.icon = params[:slack_icon]
          config.slack.webhook = params[:slack_webhook]
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
          config.smtp.domain = params[:smtp_domain]
          config.smtp.username = params[:smtp_username]
          config.smtp.password = params[:smtp_password]
          config.smtp.host = params[:smtp_host]
          config.smtp.port = params[:smtp_port]
          config.save

          redirect '/settings'
        end

        post '/bitbucket/update' do
          authenticated?
          raise ArgumentError, 'No bitbucket_key provided' unless params[:bitbucket_key]
          raise ArgumentError, 'No bitbucket_secret provided' unless params[:bitbucket_secret]

          config = configuration
          config.bitbucket.key = params[:bitbucket_key]
          config.bitbucket.secret = params[:bitbucket_secret]
          config.bitbucket.domains = params[:bitbucket_domains] if params[:bitbucket_domains]
          config.save

          redirect '/settings'
        end

        post '/github/update' do
          authenticated?
          raise ArgumentError, 'No github_key provided' unless params[:github_key]
          raise ArgumentError, 'No github_secret provided' unless params[:github_secret]

          config = configuration
          config.github.key = params[:github_key]
          config.github.secret = params[:github_secret]
          config.github.domains = params[:github_domains] if params[:github_domains]
          config.save

          redirect '/settings'
        end
      end
    end
  end
end
