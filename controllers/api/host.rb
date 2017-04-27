module Obscured
  module AptWatcher
    module Controllers
      module Api
        class Host < Obscured::AptWatcher::Controllers::Api::Base
          get '/' do
            content_type :json

            #(10..155).each do |i|
            #  Obscured::AptWatcher::Models::Host.make_and_save({:hostname => "vm-test-backend#{i}", :environment => :"#{ENV['RACK_ENV']}"})
            #end

            begin
              Obscured::AptWatcher::Models::Host.all.to_json
            rescue => e
              Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
              {:success => false, :logged => true, :message => e.message, :backtrace => e.backtrace}.to_json

              Raygun.track_exception(e)
            end
          end

          get '/:id' do
            content_type :json

            begin
              Obscured::AptWatcher::Models::Host.find(params[:id]).to_json
            rescue => e
              Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
              {:success => false, :logged => true, :message => e.message, :backtrace => e.backtrace}.to_json

              Raygun.track_exception(e)
            end
          end
        end
      end
    end
  end
end