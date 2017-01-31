require 'bcrypt'
require 'mongoid'
require 'json'
require 'rack/cache'
require 'rack-flash'
require 'slack-notifier'
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
require 'pp'
require 'warden'

STDOUT.sync = true
Mongoid.load_configuration(
clients: {
  default: {
    uri: ENV['MONGODB_URI'],
    options: {
      app_name: 'Obscured.AptWatcher',
      read: {
        mode: :secondary_preferred
      }
    }
  }
})

# pull in the models, modules, helpers and controllers
Dir.glob('./lib/{alert,common,helpers,package}/*.rb').each { |file| require file }
Dir.glob('./lib/*.rb').each { |file| require file }
Dir.glob('./lib/modules/*.rb').each { |file| require file }
Dir.glob('./models/*.rb').each { |file| require file }
Dir.glob('./controllers/*.rb').each { |file| require file }
Dir.glob('./controllers/api/*.rb').each { |file| require file }
Dir.glob('./controllers/api/collector/*.rb').each { |file| require file }

if Sinatra::Doorman::User.count == 0
  user = Sinatra::Doorman::User.make({ :username => ENV['ADMIN_EMAIL'], :password => ENV['ADMIN_PASSWORD']})
  user.set_created_from(Sinatra::Doorman::Utils::Types::SYSTEM)
  user.set_created_by(Sinatra::Doorman::Utils::Types::CONSOLE)
  user.set_name('Homer', 'Simpson')
  user.set_title(Sinatra::Doorman::Utils::Titles::GUARDIAN)
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