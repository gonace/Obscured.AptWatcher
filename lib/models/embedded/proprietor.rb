# frozen_string_literal: true

module Mongoid
  module Proprietor
    extend ActiveSupport::Concern

    included do
      field :proprietors, type: Hash, default: {}
    end

    # Get proprietor for the Document.
    #
    # @example Get a connection from connections hash.
    #   doc.get_proprietor(name)
    def get_proprietor(name)
      return proprietors[name] if proprietors.key?(name)

      nil
    end

    # Add proprietor to the proprietors field on the Document.
    #
    # @example Push an connection to connections hash.
    #   doc.set_proprietor(name, value)
    def set_proprietor(name, value)
      proprietors[name] = value
      true
    end
  end
end