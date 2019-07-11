# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'factory_bot'
require 'rack/test'
require 'rspec'
require 'simplecov'
require 'timecop'

require 'bcrypt'
require 'geocoder'
require 'haml'
require 'json'
require 'mongoid'
require 'mongoid/geospatial'
require 'neatjson'
require 'obscured-doorman'
require 'obscured-heartbeat'
require 'obscured-timeline'
require 'password_strength'
require 'rack/cache'
require 'rack/user_agent'
require 'rack-flash'
require 'raygun4ruby'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/contrib/all'
require 'sinatra/cookies'
require 'sinatra/flash'
require 'sinatra/json'
require 'sinatra/multi_route'
require 'sinatra/namespace'
require 'sinatra/partial'
require 'sinatra/sessionography'
require 'slack-notifier'
require 'sprockets'
require 'pp'
require 'warden'

SimpleCov.start do
  add_filter '/config/'
  add_filter '/spec/'
end

Mongoid.load!(File.join(File.dirname(__FILE__), '/config/mongoid.yml'), 'spec')

# pull in the models, modules, helpers and controllers
Dir.glob('./lib/extensions/*.rb').sort.each(&method(:require))
Dir.glob('./lib/*.rb').sort.each(&method(:require))
Dir.glob('./lib/{alert,common,extensions,entities,helpers,managers,package,plugins,sinatra}/*.rb').sort.each(&method(:require))
Dir.glob('./lib/modules/*.rb').sort.each(&method(:require))
Dir.glob('./lib/models/embedded/*.rb').sort.each(&method(:require))
Dir.glob('./lib/models/*.rb').sort.each(&method(:require))
Dir.glob('./controllers/*.rb').sort.each(&method(:require))
Dir.glob('./controllers/api/*.rb').sort.each(&method(:require))


RSpec.configure do |c|
  c.order = :random
  c.filter_run :focus
  c.run_all_when_everything_filtered = true

  c.include FactoryBot::Syntax::Methods
  c.include Rack::Test::Methods

  c.before(:suite) do
    FactoryBot.find_definitions
    Mongoid.purge!
    Warden.test_mode!

    SymmetricEncryption.load!('./config/encryption.yml')
  end

  c.before(:each) do
  end

  c.after(:suite) do
    Mongoid.purge!
  end
end

module AppHelper
  def self.get(klass)
    Rack::Builder.new do
      klass.helpers Sinatra::Sessionography
      Warden::Manager.serialize_into_session(&:id)
      Warden::Manager.serialize_from_session { |id| Obscured::Doorman::User.find(id) }
      use Rack::Session::Cookie, secret: 't3h_s3cr3t_is_in_th3_sauc3_', expire_after: 86_400
      use Warden::Manager
      run klass
    end.to_app
  end
end