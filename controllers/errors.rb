module Obscured
  module AptWatcher
    module Controllers
      class Errors < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/errors'


        get '/' do
          authorize!

          begin
            limit = params[:limit] ? Integer(params[:limit]) : 30
            errors = Obscured::AptWatcher::Models::Error.order_by(created_at: :desc).limit(limit)
            pagination_errors = Obscured::AptWatcher::Pagination.new(errors, Obscured::AptWatcher::Models::Error.count)

            haml :index, :locals => { :errors => pagination_errors }
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            Raygun.track_exception(e)

            flash[:error] = e.message
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

            errors = Obscured::AptWatcher::Models::Error.all.order_by(created_at: :desc).skip(skip).limit(limit)
            pagination_errors = Obscured::AptWatcher::Pagination.new(errors, Obscured::AptWatcher::Models::Error.count, page)

            partial :'partials/list', :locals => {:id => 'errors', :url => '/errors', :errors => pagination_errors}
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            Raygun.track_exception(e)

            {success: false, error: e.message}
          end
        end

        get '/view/:id' do
          authorize!

          error = Obscured::AptWatcher::Models::Error.find(params[:id]) rescue redirect('/')
          history = nil #error.history_logs.reverse { |a,b| a.created_at <=> b.created_at }

          haml :view, :locals => { :error => error, :history => history }
        end
      end
    end
  end
end