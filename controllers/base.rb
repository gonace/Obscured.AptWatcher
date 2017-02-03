module Obscured
  module AptWatcher
    module Controllers
      class Base < Sinatra::Base
        helpers Obscured::Helpers::SlackHelper
        register Sinatra::Namespace
        register Sinatra::ConfigFile
        register Sinatra::Contrib
        register Sinatra::Flash
        register Sinatra::Partial
        register Sinatra::MultiRoute

        use Rack::Session::Cookie,
            :key => 'rack.session',
            :path => '/',
            :secret => 'T58t2+6mYWAG$3TrUa@tWSm!s5+%HAWR'
        use Obscured::Doorman::Middleware
        Obscured::Doorman::Middleware.set :views, "#{File.dirname(__FILE__)}/../views/doorman"
        set :show_exceptions, :after_handler

        def warden_handler
          env['warden']
        end
        def current_user
          warden_handler.user
        end
        def authenticated?
          redirect '/doorman/login' unless warden_handler.authenticated?
        end


        error 401 do
          redirect ('/error/401')
        end

        error 403 do
          redirect ('/error/403')
        end

        error 404 do
          redirect ('/error/404')
        end

        error 408 do
          redirect ('/error/408')
        end

        error 502 do
          redirect ('/error/502')
        end

        error 503 do
          redirect ('/error/503')
        end

        error 504 do
          redirect ('/error/504')
        end

        error 500 do
          #if Tulo.c('homer.raygun.enabled')
          #  Raygun.track_exception(request.env['sinatra.error'])
          #end
          flash[:error_type] = request.env['sinatra.error'].class.name
          flash[:error_message] = request.env['sinatra.error'].to_s
          redirect ('/error/500')
        end

        error do
          #if Tulo.c('homer.raygun.enabled')
          #  Raygun.track_exception(request.env['sinatra.error'])
          #end
          flash[:error_type] = request.env['sinatra.error'].class.name
          flash[:error_message] = request.env['sinatra.error'].to_s
          redirect ('/error/500')
        end
      end
    end
  end
end