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
          #  Obscured::AptWatcher::Models::Error.make!({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
          #  flash[:error] = 'An unknown error occurred!'
          #  redirect '/'
          #end
        end

        post '/create' do
          authorize!

          #begin
            pp params
            values = params.except(:tags)
            pp values
            pp values[:hostname]
            gateway = Obscured::AptWatcher::Models::Gateway.make!(values)
            pp gateway

            params[:tags].split(",").each do |name|
              pp name
              tag = Obscured::AptWatcher::Models::Tag.upsert!(name: name, type: :default)
              pp tag
              gateway.add_tag(tag)
            end
            gateway.save

            redirect "/gateway/list"
          #rescue => e
          #  Obscured::AptWatcher::Models::Error.make!({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
          #  flash[:error] = 'An unknown error occurred!'
          #  redirect "/gateway/list"
          #end
        end
      end
    end
  end
end
