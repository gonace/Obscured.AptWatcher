module Obscured
  module AptWatcher
    module Controllers
      class Manager < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/manager'


        post '/:signature/install' do
          authorize!

          begin
            config = params.except(:signature)
            manager = Obscured::AptWatcher::Managers.get(params[:signature].to_sym)
            config[:enabled] = (params[:enabled] == "on" ? true : false)
            manager.install(config)

            redirect "/settings/managers"
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            flash[:error] = e.message
            redirect "/"
          end
        end

        post '/:signature/update' do
          authorize!

          begin
            config = params.except(:signature)
            manager = Obscured::AptWatcher::Managers.get(params[:signature].to_sym)
            config[:enabled] = (params[:enabled] == "on" ? true : false)
            manager.update(config)

            redirect "/settings/managers"
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            flash[:error] = e.message
            redirect "/"
          end
        end

        post '/:signature/uninstall' do
          authorize!

          begin
            manager = Obscured::AptWatcher::Managers.get(params[:signature].to_sym)
            manager.uninstall

            redirect "/settings/managers"
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            flash[:error] = e.message
            redirect "/"
          end
        end
      end
    end
  end
end