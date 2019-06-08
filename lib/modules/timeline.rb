# encoding: utf-8
require 'mongoid'
require 'mongoid_search'

Mongoid::Search.setup do |cfg|
  cfg.strip_symbols = /[\"]/
  cfg.strip_accents = //
end

require 'timeline/record'
require 'timeline/service'
require 'timeline/tracker'

module Mongoid
  module Timeline
  end
end