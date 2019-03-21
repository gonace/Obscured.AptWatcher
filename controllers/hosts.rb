module Obscured
  module AptWatcher
    module Controllers
      class Hosts < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/hosts'


        get '/' do
          authorize!

          begin
            limit = params[:limit] ? Integer(params[:limit]) : 30
            hosts = Obscured::AptWatcher::Models::Host.order_by(:state.asc, :hostname.asc).limit(limit)
            pagination_hosts = Obscured::AptWatcher::Helpers::Pagination.new(hosts, Obscured::AptWatcher::Models::Host.order_by(:hostname.asc).count)

            haml :index, :locals => { :hosts => pagination_hosts }
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            Raygun.track_exception(e)

            flash[:generic_error] = 'An unknown error occurred!'
            redirect '/users'
          end
        end

        get '/:page' do
          authorize!

          begin
            raise ArgumentError, 'No page number provided' unless params[:page]

            page = Integer(params[:page])
            limit = params[:limit] ? Integer(params[:limit]) : 30
            skip = (limit*page)-limit

            hosts = Obscured::AptWatcher::Models::Host.order_by(:hostname.asc).skip(skip).limit(limit)
            pagination_hosts = Obscured::AptWatcher::Helpers::Pagination.new(hosts, Obscured::AptWatcher::Models::Host.order_by(:hostname.asc).count, page)

            partial :'partials/list', :locals => {:id => 'hosts', :url => '/hosts', :hosts => pagination_hosts}
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            Raygun.track_exception(e)

            {success: false, error: e.message}
          end
        end
      end
    end
  end
end