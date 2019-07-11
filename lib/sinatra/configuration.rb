# frozen_string_literal: true

require 'sinatra/base'

module Sinatra
  # = Sinatra::Configuration
  #
  # Loads application configuration with one statement.
  #
  # == Usage
  #
  # === Classic Application
  #
  # To use the extension in a classic application all you need to do is require
  # it:
  #
  #     require "sinatra"
  #     require "sinatra/configuration"
  #
  #     # Your classic application code goes here...
  #
  # === Modular Application
  #
  # To use the extension in a modular application you need to require it, and
  # then, tell the application you will use it:
  #
  #     require "sinatra/base"
  #     require "sinatra/configuration"
  #
  #     class MyApp < Sinatra::Base
  #       register Sinatra::Configuration
  #
  #       # The rest of your modular application code goes here...
  #     end
  #
  module Configuration
    #def self.registered(base)
    #  set :configuration, Obscured::AptWatcher::Models::Configuration.where({:instance => 'aptwatcher'}).first
    #end

    def configuration
      config = Obscured::AptWatcher::Models::Configuration.where(type: :application, signature: :aptwatcher).first

      if config.nil?
        redirect '/setup'
      end
      config
    end
    alias_method :config, :configuration
  end

  helpers Configuration
end
