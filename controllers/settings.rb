module Obscured
  module AptWatcher
    module Controllers
      class Settings < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/settings'


        get '/' do
          authorize!

          unless ENV['HEROKU_TOKEN'].blank?
            heroku = PlatformAPI.connect_oauth(ENV['HEROKU_TOKEN'])
            heroku_vars = heroku.config_var.info_for_app('aptwatcher')
          else
            heroku_vars = {
              'ADMIN_EMAIL' => '',
              'ADMIN_PASSWORD' => '',
              'API_PASSWORD' => '',
              'API_USERNAME' => '',
              'HEROKU_TOKEN' => '',
              'LANG' => '',
              'MONGODB_URI' => '',
              'RACK_ENV' => '',
              'RAYGUN_KEY' => '',
              'SENDGRID_DOMAIN' => '',
              'SENDGRID_PASSWORD' => '',
              'SENDGRID_PORT' => '',
              'SENDGRID_SERVER' => '',
              'SENDGRID_USERNAME' => '',
              'SLACK_CHANNEL' => '',
              'SLACK_ICON' => '',
              'SLACK_USER' => '',
              'SLACK_WEBHOOK_URL' => '',
              'TZ' => '',
              'USER_CONFIRMATION' => '',
              'USER_REGISTRATION' => ''
            }
          end

          haml :index, :locals => { :config => heroku_vars }
        end
      end
    end
  end
end