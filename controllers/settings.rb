module Obscured
  module AptWatcher
    module Controllers
      class Settings < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/settings'


        get '/' do
          authorize!

          heroku = PlatformAPI.connect_oauth(ENV['HEROKU_TOKEN'])
          heroku_vars = heroku.config_var.info_for_app('aptwatcher')

          haml :index, :locals => { :config => heroku_vars }
        end
      end
    end
  end
end