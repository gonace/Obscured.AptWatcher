# frozen_string_literal: true

STDOUT.sync = true

require 'bcrypt'
require 'geocoder'
require 'haml'
require 'json'
require 'mongoid'
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
require 'sinatra/partial'
require 'sinatra/multi_route'
require 'sinatra/namespace'
require 'slack-notifier'
require 'sprockets'
require 'symmetric-encryption'
require 'pp'
require 'warden'

###
# SymmetricEncryption
###
SymmetricEncryption.load!('./config/encryption.yml')

###
# Haml
###
Haml::TempleEngine.disable_option_validator!

###
# Mongoid, configuration
###
Mongoid.load_configuration(
  clients: {
    default: {
      uri: ENV['MONGODB_URI'],
      options: {
        app_name: 'Obscured.AptWatcher',
        connect: :direct
      }
    }
  }
)

# pull in the models, modules, helpers and controllers
Dir.glob('./lib/*.rb').sort.each(&method(:require))
Dir.glob('./lib/{alert,common,entities,helpers,package,sinatra}/*.rb').sort.each(&method(:require))
Dir.glob('./lib/models/embedded/*.rb').sort.each(&method(:require))
Dir.glob('./lib/models/*.rb').sort.each(&method(:require))
Dir.glob('./controllers/*.rb').sort.each(&method(:require))
Dir.glob('./controllers/api/*.rb').sort.each(&method(:require))
Dir.glob('./controllers/api/collector/*.rb').sort.each(&method(:require))

###
# Configuration
###
Obscured::AptWatcher.config = Obscured::AptWatcher::Models::Configuration.where(type: :global, signature: :application)

###
# TODO: Move this into plugin and initialize when used
# Raygun, configuration
###
# if(config.raygun.enabled rescue false)
#   Raygun.setup do |cfg|
#     cfg.api_key = config.raygun.key
#   end
#   use Raygun::Middleware::RackExceptionInterceptor
# end

###
# Geocoder, configuration
###
Geocoder.configure(
  lookup: :google,
  timeout: 60,
  units: :km
)

###
# Doorman, configuration
###
doorman = Obscured::AptWatcher::Models::Configuration.where(type: :plugin, signature: :doorman).first
Obscured::Doorman.setup do |cfg|
  cfg.db_client = :default
  cfg.registration = doorman&.properties&.registration
  cfg.confirmation = doorman&.properties&.confirmation
  cfg.smtp_domain = doorman&.properties&.smtp&.domain
  cfg.smtp_server = doorman&.properties&.smtp&.host
  cfg.smtp_username = doorman&.properties&.smtp&.username
  cfg.smtp_password = doorman&.properties&.smtp&.password
  cfg.smtp_port = doorman&.properties&.smtp&.port
  cfg.providers = [
    Obscured::Doorman::Providers::Bitbucket.setup do |c|
      c.client_id = doorman&.bitbucket&.key,
      c.client_secret = doorman&.bitbucket&.secret,
      c.domains = doorman&.bitbucket&.domains
    end,
    Obscured::Doorman::Providers::GitHub.setup do |c|
      c.client_id = doorman&.github&.key,
      c.client_secret = doorman&.github&.secret,
      c.domains = doorman&.github&.domains
    end
  ]
end

###
# Routes
##
map '/' do
  run Obscured::AptWatcher::Controllers::Home
  use Rack::Static,
      urls: %w[/img /script],
      root: File.expand_path('public', __dir__)
end

map '/assets' do
  env = Sprockets::Environment.new
  env.js_compressor  = :uglify if ENV['RACK_ENV'] == 'production'
  env.css_compressor = :scss
  env.append_path 'assets/javascript'
  env.append_path 'assets/styles'
  run env

  puts "Sprockets.root           => #{env.root}"
  puts "Sprockets.paths          => #{env.paths}"
end

map '/error' do
  run Obscured::AptWatcher::Controllers::Error
end

map '/errors' do
  run Obscured::AptWatcher::Controllers::Errors
end

map '/gateway' do
  run Obscured::AptWatcher::Controllers::Gateway
end

map '/history' do
  run Obscured::AptWatcher::Controllers::History
end

map '/host' do
  run Obscured::AptWatcher::Controllers::Host
end

map '/manager' do
  run Obscured::AptWatcher::Controllers::Manager
end

map '/me' do
  run Obscured::AptWatcher::Controllers::Me
end

map '/notifications' do
  run Obscured::AptWatcher::Controllers::Notifications
end

map '/plugin' do
  run Obscured::AptWatcher::Controllers::Plugin
end

map '/scan' do
  run Obscured::AptWatcher::Controllers::Scan
end

map '/settings' do
  run Obscured::AptWatcher::Controllers::Settings
end

map '/setup' do
  run Obscured::AptWatcher::Controllers::Setup
end

map '/statistics' do
  run Obscured::AptWatcher::Controllers::Statistics
end

map '/users' do
  run Obscured::AptWatcher::Controllers::Users
end

###
# API Routs
##
map '/api/collector/notification' do
  run Obscured::AptWatcher::Controllers::Api::Collector::Notification
end

map '/api/collector/upgrades' do
  run Obscured::AptWatcher::Controllers::Api::Collector::Upgrades
end

map '/api/alerts' do
  run Obscured::AptWatcher::Controllers::Api::Notification
end

map '/api/hosts' do
  run Obscured::AptWatcher::Controllers::Api::Host
end

map '/api/matcher' do
  run Obscured::AptWatcher::Controllers::Api::Matcher
end

map '/api/scans' do
  run Obscured::AptWatcher::Controllers::Api::Scan
end
