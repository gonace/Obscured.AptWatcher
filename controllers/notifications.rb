module Obscured
  module AptWatcher
    module Controllers
      class Notifications < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/notifications'


        get '/' do
          authorize!

          alerts = Obscured::AptWatcher::Models::Alert.all.order_by(created_at: :desc, :status => Obscured::Status::OPEN)

          haml :index, :locals => { :alerts => alerts }
        end

        get '/:page' do
          authorize!

          alerts = Obscured::AptWatcher::Models::Alert.all.order_by(created_at: :desc, :status => Obscured::Status::OPEN)

          haml :index, :locals => { :alerts => alerts }
        end

        get '/view/:id' do
          authorize!

          alert = Obscured::AptWatcher::Models::Alert.find(params[:id]) rescue redirect('/')
          #history = alert.history_logs.sort_by &:created
          #[0,10]
          history = alert.history_logs.reverse { |a,b| a.created_at <=> b.created_at }

          haml :notification, :locals => { :alert => alert, :history => history }
        end

        post '/view/:id/update' do
          authorize!

          begin
            action = params[:action]
            alert = Obscured::AptWatcher::Models::Alert.find(params[:id]) rescue redirect('/')

            if action == 'resolve'
              flash[:save_ok] = 'The alert is marked as closed/resolved'
              alert.status = Obscured::Status::CLOSED
              alert.add_history_log("Changed status to #{alert.status}", user.username)
            elsif action == 'reopen'
              flash[:save_warning] = 'The alert is marked as open'
              alert.status = Obscured::Status::OPEN
              alert.add_history_log("Changed status to #{alert.status}", user.username)
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