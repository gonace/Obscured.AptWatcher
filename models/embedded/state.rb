module Mongoid
  module State
    extend ActiveSupport::Concern

    included do
      field :state, type: String, :default => Obscured::State::UNKNOWN
      set_callback :update, :before, :set_state
    end

    # Update the state field on the Document to the connected state.
    # This is only called on create and on save (update).
    #
    # @example Set the updated at time.
    #   host.set_state
    def set_state
      if able_to_set_updated_at?
        self.state = Obscured::State::CONNECTED
      end
    end
  end
end