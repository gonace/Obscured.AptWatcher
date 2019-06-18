module Obscured
  module AptWatcher
    module Controllers
      class Manager < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/manager'


        post '/:signature/install' do
          authorize!

          begin
            manager = Obscured::AptWatcher::Managers.get(params[:signature].to_sym)
            manager.install({ enabled: (params[:enabled] == "on" ? true : false) })

            redirect "/settings/managers"
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            flash[:error] = "We're sad to announce that we could not update permissions for (#{user.username})"
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
            flash[:error] = "We're sad to announce that we could not update permissions for (#{user.username})"
            redirect "/"
          end
        end
      end
    end
  end
end