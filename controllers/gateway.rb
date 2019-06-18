module Obscured
  module AptWatcher
    module Controllers
      class Gateway < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/gateway'


        get '/', '/list' do
          authorize!

          #begin
            limit = params[:limit] ? Integer(params[:limit]) : 30
            hosts = Obscured::AptWatcher::Models::Gateway.order_by(:hostname.asc).limit(limit)
            model = Obscured::AptWatcher::Pagination.new(hosts, Obscured::AptWatcher::Models::Gateway.order_by(:hostname.asc).count)

            haml :list, :locals => {
              :model => model
            }
          #rescue => e
          #  Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
          #  Raygun.track_exception(e)

          #  flash[:error] = 'An unknown error occurred!'
          #  redirect '/'
          #end
        end
      end
    end
  end
end
