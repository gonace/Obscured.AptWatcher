module Mongoid
  module State
    extend ActiveSupport::Concern

    included do
      field :state, type: Symbol, :default => Obscured::State::PENDING
      set_callback :create, :before, :set_state_pending
    end

    # Update the state field on the Document to the provided state.
    # This is only called on create and on save (update).
    #
    # @example Set the updated at time.
    #   host.set_state
    def set_state(state)
      self.set({:state => state}) if state.is_a?(Symbol)
    end


    protected

    # Update the state field on the Document to the pending state.
    # This is only called on create and on save (create).
    #
    # @example Set the updated at time.
    #   host.set_state_pending
    def set_state_pending
      self.state = Obscured::State::PENDING
    end
  end
end