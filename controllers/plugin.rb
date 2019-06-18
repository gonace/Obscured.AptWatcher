module Obscured
  module AptWatcher
    module Controllers
      class Plugin < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/plugin'


      end
    end
  end
end