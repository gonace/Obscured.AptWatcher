# frozen_string_literal: true

module Obscured
  module AptWatcher
    module Controllers
      module Api
        class Base < Sinatra::Base
          helpers Obscured::Helpers::SlackHelper
          helpers Sinatra::Configuration

          config = Obscured::AptWatcher::Models::Configuration.where(:instance => 'aptwatcher').first
          api_username = config&.username
          api_password = config&.password

          unless api_username.blank?
            use Rack::Auth::Basic do |username, password|
              username == api_username && password == api_password
            end
          end
        end
      end
    end
  end
end
