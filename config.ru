STDOUT.sync = true

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
#require 'platform-api'
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

# pull in the models, modules, helpers and controllers
Dir.glob('./lib/{alert,common,entities,helpers,package,sinatra}/*.rb').sort.each(&method(:require))
Dir.glob('./lib/*.rb').sort.each(&method(:require))
Dir.glob('./lib/modules/*.rb').sort.each(&method(:require))
Dir.glob('./models/embedded/*.rb').sort.each(&method(:require))
Dir.glob('./models/*.rb').sort.each(&method(:require))
Dir.glob('./controllers/*.rb').sort.each(&method(:require))
Dir.glob('./controllers/api/*.rb').sort.each(&method(:require))
Dir.glob('./controllers/api/collector/*.rb').sort.each(&method(:require))

###
# Configuration
###
config = Obscured::AptWatcher::Models::Configuration.where({:instance => 'aptwatcher'}).first

###
# Raygun, configuration
###
if (config.raygun.enabled rescue false)
  Raygun.setup do |cfg|
    cfg.api_key = config.raygun.key
  end
  use Raygun::Middleware::RackExceptionInterceptor
end

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
  :registration    => (config.user_registration rescue false),
  :confirmation    => (config.user_confirmation rescue false),
  :smtp_domain     => (config.smtp.domain rescue 'obscured.se'),
  :smtp_server     => (config.smtp.host rescue 'localhost'),
  :smtp_username   => (config.smtp.username rescue nil),
  :smtp_password   => (config.smtp.password rescue nil),
  :smtp_port       => (config.smtp.port rescue 587),
  :providers       => [
    Obscured::Doorman::Providers::Bitbucket.configure(
      :client_id       => (config.bitbucket.key rescue nil),
      :client_secret   => (config.bitbucket.secret rescue nil),
      :valid_domains   => (config.bitbucket.domains rescue nil)
    ),
    Obscured::Doorman::Providers::GitHub.configure(
      :client_id       => (config.github.key rescue nil),
      :client_secret   => (config.github.secret rescue nil),
      :valid_domains   => (config.github.domains rescue nil)
    )
  ]
)


###
# Routes
##
map '/' do
  run Obscured::AptWatcher::Controllers::Home
  use Rack::Static, :urls => %w(/css /img /script /assets /fonts), :root => File.expand_path('../public', __FILE__)
end

map '/assets' do
  env = Sprockets::Environment.new
  env.js_compressor  = :uglify if ENV['RACK_ENV'] == 'production'
  env.css_compressor = :scss
  env.append_path 'assets/javascript'
  env.append_path 'assets/styles'
  run env
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