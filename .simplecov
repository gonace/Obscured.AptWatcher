SimpleCov.start do
  add_filter 'namespace'
  add_filter 'version'
  add_filter '/spec/'

  add_group "Alert", "lib/alert"
  add_group "Common", "lib/common"
  add_group "Controllers", "controllers"
  add_group "Extensions", "lib/extensions"
  add_group "Helpers", "lib/helpers"
  add_group "Managers", "lib/managers"
  add_group "Models", "lib/models"
  add_group "Plugins", "lib/plugins"
  add_group "Sinatra", "lib/sinatra"

  track_files '{lib}/**/*.rb'
end