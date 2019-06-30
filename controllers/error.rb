# frozen_string_literal: true

module Obscured
  module AptWatcher
    module Controllers
      class Error < Sinatra::Base
        register Sinatra::ConfigFile
        register Sinatra::Flash
        register Sinatra::Partial

        use Rack::Session::Cookie,
            key: 'rack.session',
            path: '/',
            secret: 'T58t2+6mYWAG$3TrUa@tWSm!s5+%HAWR'

        set :views, settings.root + '/../views/error'


        get '/401' do
          status 401
          haml :Unauthorized, locals: { title: '401: The request requires user authentication.' }
        end

        get '/403' do
          status 403
          haml :Forbidden, locals: { title: '403: The server understood the request, but is refusing to fulfill it.' }
        end

        get '/404' do
          status 404
          haml :NotFound, locals: { title: 'Page Not Found', message: "We can't seem to find the page you're looking for." }
        end

        get '/408' do
          status 408
          haml :Timeout, locals: { title: '408: The client did not produce a request within the time that the server was prepared to wait..' }
        end

        get '/500' do
          status 500
          haml :Error, locals: { title: '500: Something went wrong' }
        end

        get '/502' do
          status 502
          haml :BadGateway, locals: { title: '502: The server, while acting as a gateway or proxy, received an invalid response from the upstream server it accessed in attempting to fulfill the request.' }
        end

        get '/503' do
          status 503
          haml :Unavailable, locals: { title: '503: The server is currently unable to handle the request due to a temporary overloading or maintenance of the server.' }
        end

        get '/504' do
          status 504
          haml :GatewayTimeout, locals: { title: '504: The server, while acting as a gateway or proxy, did not receive a timely response from the upstream server.' }
        end
      end
    end
  end
end
