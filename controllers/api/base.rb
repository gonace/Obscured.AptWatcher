module Obscured
  module AptWatcher
    module Controllers
      module Api
        class Base < Sinatra::Base
          helpers Obscured::Helpers::SlackHelper

          if ENV['AUTH_USERNAME'].to_s != ''
            use Rack::Auth::Basic do |username, password|
              username == ENV['AUTH_USERNAME'] && password == ENV['AUTH_PASSWORD']
            end
          end
        end
      end
    end
  end
end