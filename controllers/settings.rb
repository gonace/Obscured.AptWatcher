module Obscured
  module AptWatcher
    module Controllers
      class Settings < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/settings'


        get '/' do
          authenticated?

          haml :index, :locals => { }
        end
      end
    end
  end
end