module Obscured
  module Doorman
    class HistoryLog
      include Mongoid::Document
      include Mongoid::Timestamps
      field :text, type: String
      field :created_by, type: String
      #field :created_at, type: DateTime, default: -> {DateTime.now}

      embedded_in :history, polymorphic: true

      def self.make(text, user)
        h = self.new
        h.text = text
        h.created_by = user
        h
      end
    end
  end
end