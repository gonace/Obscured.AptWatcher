module Obscured
  module AptWatcher
    module Controllers
      class Me < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/me'


        get '/', '/profile' do
          authorize!

          begin
            user = Obscured::Doorman::User.find(current_user.id)
            timeline = user.find_events({}, { limit: 20 })

            haml :profile, locals: {
              user: user,
              timeline: timeline
            }
          rescue => e
            Obscured::AptWatcher::Models::Error.make!({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            flash[:error] = e.message
            redirect '/'
          end
        end

        get '/password' do
          authorize!

          begin

            haml :password, :locals => {
            }
          rescue => e
            Obscured::AptWatcher::Models::Error.make!({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            flash[:error] = e.message
            redirect '/'
          end
        end

        get '/notifications' do
          authorize!

          begin

            haml :notifications, :locals => {
            }
          rescue => e
            Obscured::AptWatcher::Models::Error.make!({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            flash[:error] = e.message
            redirect '/'
          end
        end
      end
    end
  end
end