# frozen_string_literal: true

module Mongoid
  # This module handles the behaviour for setting up document for
  # tags.
  module Tags
    extend ActiveSupport::Concern

    included do
      has_and_belongs_to_many :tags, inverse_of: nil, class_name: 'Obscured::AptWatcher::Models::Tag'
    end

    # Adds tag to document and returns the document. This is
    # only called on manually.
    #
    # @example Set the add_tag.
    #   doc.add_tag
    #
    # @return [ document ]
    def add_tag(tag)
      return false if tags.detect { |t| t == tag }

      tags << tag
    end

    # Removes tag id from array. This is
    # only called on manually.
    #
    # @example Set the remove_tag.
    #   doc.remove_tag
    #
    # @return [ document ]
    def remove_tag(tag)
      return false unless tags.detect { |t| t == tag }

      tags.delete(tag)
    end

    # Removes all tags. This is
    # only called on manually.
    #
    # @example Set the clear_tags.
    #   doc.clear_tags
    #
    # @return [ document ]
    def clear_tags
      tags.clear
    end
  end
end
