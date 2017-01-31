module Obscured
  module AptWatcher
    module Controllers
      class History < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/history'


        get '/' do
          authenticated?

          begin
            limit = params[:limit] ? Integer(params[:limit]) : 30
            scans = Obscured::AptWatcher::Models::Scan.order_by(:created_at.desc).limit(limit)
            pagination_scans = Obscured::AptWatcher::Helpers::Pagination.new(scans, Obscured::AptWatcher::Models::Scan.order_by(:created_at.desc).limit(limit).count)

            haml :index, :locals => { :scans => pagination_scans }
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})

            flash[:generic_error] = e.message
            redirect '/'
          end
        end


        get '/:page' do
          authenticated?

          begin
            raise ArgumentError, 'No page number provided' unless params[:page]

            page = Integer(params[:page])
            limit = params[:limit] ? Integer(params[:limit]) : 30
            skip = (limit*page)-limit

            scans = Obscured::AptWatcher::Models::Scan.order_by(:created_at.desc).skip(skip).limit(limit)
            pagination_scans = Obscured::AptWatcher::Helpers::Pagination.new(scans, Obscured::AptWatcher::Models::Scan.order_by(:created_at.desc).count, page)

            partial :'partials/list', :locals => {:id => 'hosts', :url => '/history', :scans => pagination_scans}
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})

            {success: false, error: e.message}
          end
        end
      end
    end
  end
end