STDOUT.sync = true

require 'bcrypt'
require 'geocoder'
require 'haml'
require 'json'
require 'mongoid'
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
require 'platform-api'
require 'pp'
require 'warden'

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
})

###
# Raygun, configuration
###
Raygun.setup do |config|
  config.api_key = ENV['RAYGUN_KEY']
end
use Raygun::Middleware::RackExceptionInterceptor


# pull in the models, modules, helpers and controllers
Dir.glob('./lib/{alert,common,helpers,package}/*.rb').sort.each { |file| require file }
Dir.glob('./lib/*.rb').sort.each { |file| require file }
Dir.glob('./lib/modules/*.rb').sort.each { |file| require file }
Dir.glob('./models/embeded/*.rb').sort.each { |file| require file }
Dir.glob('./models/*.rb').sort.each { |file| require file }
Dir.glob('./controllers/*.rb').sort.each { |file| require file }
Dir.glob('./controllers/api/*.rb').sort.each { |file| require file }
Dir.glob('./controllers/api/collector/*.rb').sort.each { |file| require file }

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
Obscured::Doorman.configure(
  :confirmation => ENV['USER_CONFIRMATION'],
  :registration => ENV['USER_REGISTRATION'],
  :smtp_domain => ENV['SENDGRID_DOMAIN'],
  :smtp_server => ENV['SENDGRID_SERVER'],
  :smtp_password => ENV['SENDGRID_PASSWORD'],
  :smtp_port => ENV['SENDGRID_PORT'],
  :smtp_username => ENV['SENDGRID_USERNAME']
)

if Obscured::Doorman::User.count == 0
  user = Obscured::Doorman::User.make({:username => ENV['ADMIN_EMAIL'], :password => ENV['ADMIN_PASSWORD']})
  user.set_created_from(Obscured::Doorman::Types::SYSTEM)
  user.set_created_by(Obscured::Doorman::Types::CONSOLE)
  user.set_name('Homer', 'Simpson')
  user.set_title(Obscured::Doorman::Titles::GUARDIAN)
  user.save
end


###
# Routes
##
map '/' do
  run Obscured::AptWatcher::Controllers::Home
  use Rack::Static, :urls => %w(/css /img /script /assets /fonts), :root => File.expand_path('../public', __FILE__)
end

map '/error' do
  run Obscured::AptWatcher::Controllers::Error
end

map '/errors' do
  run Obscured::AptWatcher::Controllers::Errors
end

map '/history' do
  run Obscured::AptWatcher::Controllers::History
end

map '/host' do
  run Obscured::AptWatcher::Controllers::Host
end

map '/hosts' do
  run Obscured::AptWatcher::Controllers::Hosts
end

map '/notifications' do
  run Obscured::AptWatcher::Controllers::Notifications
end

map '/scan' do
  run Obscured::AptWatcher::Controllers::Scan
end

map '/settings' do
  run Obscured::AptWatcher::Controllers::Settings
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