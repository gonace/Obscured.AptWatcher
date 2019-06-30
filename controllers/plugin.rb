# frozen_string_literal: true

module Obscured
  module AptWatcher
    module Controllers
      class Plugin < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/plugin'


        post '/:signature/install' do
          authorize!

          begin
            config = params.except(:signature)
            plugin = Obscured::AptWatcher::Plugins.get(params[:signature].to_sym)
            config[:enabled] = params[:enabled] == 'on'
            plugin.install(config)

            redirect '/settings/plugins'
          rescue => e
            Obscured::AptWatcher::Models::Error.make!(notifier: Obscured::Alert::Type::SYSTEM, message: e.message, backtrace: e.backtrace.join('<br />'))
            flash[:error] = e.message
            redirect '/'
          end
        end

        post '/:signature/update' do
          authorize!

          begin
            config = params.except(:signature)
            plugin = Obscured::AptWatcher::Plugins.get(params[:signature].to_sym)
            config[:enabled] = params[:enabled] == 'on'
            plugin.update(config)

            redirect '/settings/plugins'
          rescue => e
            Obscured::AptWatcher::Models::Error.make!(notifier: Obscured::Alert::Type::SYSTEM, message: e.message, backtrace: e.backtrace.join('<br />'))
            flash[:error] = e.message
            redirect '/'
          end
        end

        post '/:signature/uninstall' do
          authorize!

          begin
            plugin = Obscured::AptWatcher::Plugins.get(params[:signature].to_sym)
            plugin.uninstall

            redirect '/settings/plugins'
          rescue => e
            Obscured::AptWatcher::Models::Error.make!(notifier: Obscured::Alert::Type::SYSTEM, message: e.message, backtrace: e.backtrace.join('<br />'))
            flash[:error] = e.message
            redirect '/'
          end
        end
      end
    end
  end
end
