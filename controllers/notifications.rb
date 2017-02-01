module Obscured
  module AptWatcher
    module Controllers
      class Notifications < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/notifications'


        get '/' do
          authenticated?

          alerts = Obscured::AptWatcher::Models::Alert.all.order_by(created_at: :desc, :status => Obscured::Status::OPEN)

          haml :index, :locals => { :alerts => alerts }
        end

        get '/:page' do
          authenticated?

          alerts = Obscured::AptWatcher::Models::Alert.all.order_by(created_at: :desc, :status => Obscured::Status::OPEN)

          haml :index, :locals => { :alerts => alerts }
        end

        get '/view/:id' do
          authenticated?

          alert = Obscured::AptWatcher::Models::Alert.find(params[:id]) rescue redirect('/')

          haml :notification, :locals => { :alert => alert }
        end

        post '/view/:id/update' do
          authenticated?

          begin
            action = params[:action]
            alert = Obscured::AptWatcher::Models::Alert.find(params[:id]) rescue redirect('/')

            if action == 'resolve'
              flash[:save_ok] = 'The alert is marked as closed/resolved'
              alert.status = Obscured::Status::CLOSED
            elsif action == 'reopen'
              flash[:save_warning] = 'The alert is marked as closed/resolved'
              alert.status = Obscured::Status::OPEN
            end
            alert.save!

            redirect "/notifications/view/#{params[:id]}"
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})

            flash[:save_error] = "We're sad to say that an error occurred with the message: #{e.message}"
            redirect "/notifications/view/#{params[:id]}"
          end
        end
      end
    end
  end
end