require 'mongoid'
require 'mongoid_search'

Mongoid::Search.setup do |cfg|
  cfg.strip_symbols = /[\"]/
  cfg.strip_accents = //
end

require 'heartbeat/record'
require 'heartbeat/service'
require 'heartbeat/tracker'

module Mongoid
  module Heartbeat
  end
end