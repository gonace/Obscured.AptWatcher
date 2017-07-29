module Obscured
  module AptWatcher
    module Controllers
      class Setup < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/setup'

        before do
          config = (Obscured::AptWatcher::Models::Configuration.where({:instance => 'aptwatcher'}).first rescue true)
          unless config.nil?
            redirect '/doorman/login'
          end
        end

        get '/' do
          haml :index
        end

        post '/' do
          unless params[:secret].to_s.eql? ENV['SETUP_AUTHORIZATION'].to_s
            flash[:error] = 'The setup secret provided is invalid or missing'
            redirect '/setup'
          end

          redirect "/setup/define/#{params[:secret]}"
        end


        get '/define/:secret' do
          unless params[:secret].to_s.eql? ENV['SETUP_AUTHORIZATION'].to_s
            flash[:error] = 'The setup secret provided is invalid or missing'
            redirect '/setup'
          end


          haml :setup, :locals => { :secret => params[:secret] }
        end


        post '/define' do
          puts '=== DEBUG ==='
          pp params
          puts '============='

          unless params[:secret].to_s.eql? ENV['SETUP_AUTHORIZATION'].to_s
            flash[:error] = 'The setup secret provided is invalid or missing'
            redirect '/setup'
          end

          config = Obscured::AptWatcher::Models::Configuration.make({:instance => 'aptwatcher'})
          config.instance = 'aptwatcher'
          config.save

          user = Obscured::Doorman::User.make({:username => params[:user][:login], :password => params[:user][:password]})
          user.set_created_from(Obscured::Doorman::Types::ADMIN)
          user.set_created_by(Obscured::Doorman::Types::SETUP)
          user.set_name(params[:user][:first_name], params[:user][:last_name])
          user.save


          redirect '/doorman/login'
        end
      end
    end
  end
end