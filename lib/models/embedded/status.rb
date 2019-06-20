module Mongoid
  module Status
    extend ActiveSupport::Concern

    included do
      field :status, type: Symbol, :default => :offline
      set_callback :create, :before, :set_status_pending
    end

    # Update the status field on the Document to the provided status.
    # This is only called on create and on save (update).
    #
    # @example Set the updated at time.
    #   host.set_status(:symbol)
    def set_status(status)
      self.set({:status => status}) if status.is_a?(Symbol)
    end


    private

    # Update the status field on the Document to the pending status.
    # This is only called on create and on save (create).
    #
    # @example Set the updated at time.
    #   host.set_status_pending
    def set_status_pending
      self.status = :pending
    end
  end
end