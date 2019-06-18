$LOAD_PATH.unshift File.dirname(__FILE__)
require 'factory_bot'
require 'rspec'
require 'timecop'

require 'bcrypt'
require 'geocoder'
require 'haml'
require 'json'
require 'mongoid'
require 'neatjson'
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
require 'sinatra/partial'
require 'sinatra/multi_route'
require 'sinatra/namespace'
require 'slack-notifier'
require 'sprockets'
require 'pp'
require 'warden'


Mongoid.load!(File.join(File.dirname(__FILE__), '/config/mongoid.yml'), 'spec')

# pull in the models, modules, helpers and controllers
Dir.glob('./lib/*.rb').sort.each(&method(:require))
Dir.glob('./lib/{alert,common,entities,helpers,managers,package,plugins,sinatra}/*.rb').sort.each(&method(:require))
Dir.glob('./lib/modules/*.rb').sort.each(&method(:require))
Dir.glob('./lib/models/embedded/*.rb').sort.each(&method(:require))
Dir.glob('./lib/models/*.rb').sort.each(&method(:require))


RSpec.configure do |c|
  c.order = :random
  c.filter_run :focus
  c.run_all_when_everything_filtered = true

  c.before(:suite) do
    FactoryBot.find_definitions
  end

  c.before(:each) do
  end
end