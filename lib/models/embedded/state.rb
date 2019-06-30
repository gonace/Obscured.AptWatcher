# frozen_string_literal: true

module Mongoid
  module State
    extend ActiveSupport::Concern

    included do
      field :state, type: Symbol, default: :pending
      set_callback :create, :before, :set_state_pending
    end

    # Update the state field on the Document to the provided state.
    # This is only called on create and on save (update).
    #
    # @example Set the updated at time.
    #   doc.set_state(:symbol)
    def set_state(state)
      self.state = state if state.is_a?(Symbol)
    end


    private

    # Update the state field on the Document to the pending state.
    # This is only called on create and on save (create).
    #
    # @example Set the updated at time.
    #   doc.set_state_pending
    def set_state_pending
      self.state = :pending
    end
  end
end
