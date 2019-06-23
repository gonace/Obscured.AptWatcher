require 'mongoid'
require 'mongoid_search'

Mongoid::Search.setup do |cfg|
  cfg.strip_symbols = /[\"]/
  cfg.strip_accents = //
end

require_relative 'timeline/record'
require_relative 'timeline/service'
require_relative 'timeline/tracker'

module Mongoid
  module Timeline
  end
end