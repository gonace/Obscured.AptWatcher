# frozen_string_literal: true

module Obscured
  module AptWatcher
    module Controllers
      class Settings < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/settings'


        get '/' do
          authorize!

          puts '=== DEBUG ==='
          pp configuration
          pp configuration.properties[:registration]
          puts '============='

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

        post '/:feature/:action' do
          authenticated?
          content_type :json

          begin
            enabled = (params[:action] == 'enable')
            feature = params[:feature].to_sym

            config = Obscured::AptWatcher::Models::Configuration.find_or_create_by(type: :application, signature: :aptwatcher)
            config.properties[feature] = enabled
            config.save

            Obscured::AptWatcher::Entities::Ajax::Response.new(enabled: enabled).to_json
          rescue StandardError => e
            Obscured::AptWatcher::Entities::Ajax::Error.new(e.message, e.class.name, false).to_json
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
      end
    end
  end
end
