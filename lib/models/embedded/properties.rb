module Mongoid
  module Properties
    extend ActiveSupport::Concern

    included do
      field :properties, type: Hash, default: {}
    end

    # Get property for the Document.
    #
    # @example Get an property from properties hash.
    #   job.get_property(name)
    def get_property(name)
      return self.properties[name] if self.properties.has_key?(name)
      nil
    end

    # Add property to the properties field on the Document.
    #
    # @example Push an property to properties hash.
    #   job.set_property(name, value)
    def set_property(name, value)
      self.properties[name] = value
      true
    end
  end
end