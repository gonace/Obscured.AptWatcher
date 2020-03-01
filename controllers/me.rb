# frozen_string_literal: true

module Obscured
  module AptWatcher
    module Controllers
      class Me < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/me'

        before do
          @user = Obscured::Doorman::User.find(current_user.id)
          @timeline = @user.find_events({}, limit: 20)

          redirect '/' if @user.nil?
        end

        get '/', '/profile' do
          authorize!

          begin

            haml :profile, locals: {
              user: @user,
              timeline: @timeline
            }
          rescue => e
            Obscured::AptWatcher::Models::Error.make!(notifier: Obscured::Alert::Type::SYSTEM, message: e.message, backtrace: e.backtrace.join('<br />'))
            flash[:error] = e.message
            redirect '/'
          end
        end

        get '/password' do
          authorize!

          begin

            haml :password, locals: {
              user: @user,
              timeline: @timeline
            }
          rescue => e
            Obscured::AptWatcher::Models::Error.make!(notifier: Obscured::Alert::Type::SYSTEM, message: e.message, backtrace: e.backtrace.join('<br />'))
            flash[:error] = e.message
            redirect '/'
          end
        end

        get '/notifications' do
          authorize!

          begin

            haml :notifications, locals: {
              user: @user,
              timeline: @timeline
            }
          rescue => e
            Obscured::AptWatcher::Models::Error.make!(notifier: Obscured::Alert::Type::SYSTEM, message: e.message, backtrace: e.backtrace.join('<br />'))
            flash[:error] = e.message
            redirect '/'
          end
        end

        private

        def status(type)
          if type.to_s == 'password'
            'danger'
          elsif type.to_s == 'account'
            'info'
          elsif type.to_s == 'confirmation'
            'warning'
          elsif type.to_s == 'remember'
            'warning'
          else
            'dark'
          end
        end
      end
    end
  end
end