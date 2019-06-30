# frozen_string_literal: true

module Mongoid
  module Properties
    extend ActiveSupport::Concern

    included do
      field :properties, type: Hash, default: {}
    end

    # Get property for the Document.
    #
    # @example Get an property from properties hash.
    #   doc.get_property(name)
    def get_property(name)
      return properties[name] if properties.key?(name)

      nil
    end

    # Add property to the properties field on the Document.
    #
    # @example Push an property to properties hash.
    #   doc.set_property(name, value)
    def set_property(name, value)
      properties[name] = value
      true
    end
  end
end
