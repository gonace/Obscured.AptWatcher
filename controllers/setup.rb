# frozen_string_literal: true

module Obscured
  module AptWatcher
    module Controllers
      class Setup < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/setup'

        before do
          config = Obscured::AptWatcher.config.where(signature: :application).first
          redirect '/doorman/login' unless config.nil?
        end

        get '/' do
          haml :index
        end

        post '/' do
          unless params[:secret].to_s.eql? ENV['SETUP_AUTHORIZATION'].to_s
            flash[:error] = 'The setup secret provided is invalid or missing'
            redirect '/setup'
          end

          redirect "/setup/register/#{params[:secret]}"
        end


        get '/register/:secret' do
          unless params[:secret].to_s.eql? ENV['SETUP_AUTHORIZATION'].to_s
            flash[:error] = 'The setup secret provided is invalid or missing'
            redirect '/setup'
          end


          haml :setup, locals: { secret: params[:secret] }
        end

        post '/register' do
          unless params[:secret].to_s.eql? ENV['SETUP_AUTHORIZATION'].to_s
            flash[:error] = 'The setup secret provided is invalid or missing'
            redirect '/setup'
          end

          config = Models::Configuration.make(type: :application, signature: :aptwatcher, properties: { intsalled: true })
          config.save

          pp params
          pp params[:user][:first_name]

          user = Obscured::Doorman::User.make(username: params[:user][:email], password: params[:user][:password])
          user.name = { first_name: params[:user][:first_name], last_name: params[:user][:last_name] }
          user.save

          warden.authenticate(:password)
          cookies[:email] = user.username

          redirect '/setup/managers'
        end


        get '/managers' do
          managers = Obscured::AptWatcher::Managers.all.sort_by(&:signature)

          haml :managers, locals: {
            managers: managers
          }
        end

        post '/managers' do
          redirect '/setup/plugins'
        end


        get '/plugins' do
          plugins = Obscured::AptWatcher::Plugins.all.sort_by(&:signature)

          haml :plugins, locals: {
            plugins: plugins
          }
        end

        post '/plugins' do
          redirect '/home'
        end
      end
    end
  end
end
