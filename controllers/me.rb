module Obscured
  module AptWatcher
    module Controllers
      class Me < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/me'


        get '/', '/profile' do
          authorize!

          begin

            haml :profile, :locals => {  }
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            Raygun.track_exception(e)

            flash[:error] = e.message
            redirect '/'
          end
        end
      end
    end
  end
end