require 'mongoid'
require 'mongoid_search'

Mongoid::Search.setup do |cfg|
  cfg.strip_symbols = /[\"]/
  cfg.strip_accents = //
end

require_relative 'heartbeat/record'
require_relative 'heartbeat/service'
require_relative 'heartbeat/tracker'

module Mongoid
  module Heartbeat
  end
end