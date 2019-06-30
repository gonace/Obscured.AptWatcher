# frozen_string_literal: true

module Obscured
  module AptWatcher
    module Host
      class Filter
        attr_accessor :hostname

        def initialize(args)
          @hostname = args[:hostname].blank? ? nil : args[:hostname]
        end

        def to_hash
          query = {}
          query.merge!(hostname: @hostname) unless @hostname.blank?
          query
        end
        alias to_h to_hash

        def to_query
          uri = Addressable::URI.new
          uri.query_values = to_hash
          uri.query
        end
        alias to_q to_query
      end
    end
  end
end
