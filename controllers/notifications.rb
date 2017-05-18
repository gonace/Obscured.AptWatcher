module Obscured
  module AptWatcher
    module Controllers
      class Notifications < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/notifications'


        get '/' do
          authorize!

          begin
            limit = params[:limit] ? Integer(params[:limit]) : 30
            alerts = Obscured::AptWatcher::Models::Alert.order_by(created_at: :desc).limit(limit)
            pagination_alerts = Obscured::AptWatcher::Helpers::Pagination.new(alerts, Obscured::AptWatcher::Models::Alert.order_by(created_at: :desc, :status => Obscured::Status::OPEN).count)

            haml :index, :locals => { :alerts => pagination_alerts }
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            Raygun.track_exception(e)

            flash[:generic_error] = e.message
            redirect '/'
          end
        end

        get '/:page' do
          authorize!

          begin
            raise ArgumentError, 'No page number provided' unless params[:page]

            page = Integer(params[:page])
            limit = params[:limit] ? Integer(params[:limit]) : 30
            skip = (limit*page)-limit

            alerts = Obscured::AptWatcher::Models::Alert.all.order_by(created_at: :desc).skip(skip).limit(limit)
            pagination_scans = Obscured::AptWatcher::Helpers::Pagination.new(alerts, Obscured::AptWatcher::Models::Alert.order_by(:created_at.desc).count, page)

            partial :'partials/list', :locals => {:id => 'alerts', :url => '/notifications', :alerts => pagination_scans}
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            Raygun.track_exception(e)

            {success: false, error: e.message}
          end
        end

        get '/view/:id' do
          authorize!

          alert = Obscured::AptWatcher::Models::Alert.find(params[:id]) rescue redirect('/')
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
            Raygun.track_exception(e)

            flash[:save_error] = "We're sad to say that an error occurred with the message: #{e.message}"
            redirect "/notifications/view/#{params[:id]}"
          end
        end
      end
    end
  end
end