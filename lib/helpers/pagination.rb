# frozen_string_literal: true

module Obscured
  module AptWatcher
    class Pagination
      attr_accessor :items
      attr_accessor :properties

      class Properties
        attr_accessor :length
        attr_accessor :page
        attr_accessor :page_size
        attr_accessor :page_first
        attr_accessor :page_last

        def initialize(length, page, page_size, page_first, page_last)
          @length = length
          @page = page
          @page_size = page_size
          @page_first = page_first
          @page_last = page_last
        end
      end

      def initialize(items, length, page = 1, page_size = 30, page_first = 1, page_last = (length.to_f/page_size.to_f).ceil)
        @items = items
        @properties = Properties.new(length, page, page_size, page_first, page_last)
      end
    end
  end
end
