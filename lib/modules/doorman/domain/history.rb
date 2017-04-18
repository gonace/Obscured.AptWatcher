module Obscured
  module Doorman
    class HistoryLog
      include Mongoid::Document
      field :text, type: String
      field :user, type: String
      field :created_at, type: DateTime, default: -> {DateTime.now}

      embedded_in :history, polymorphic: true

      def self.make(text, user)
        h = self.new
        h.text = text
        h.user = user
        h
      end
    end
  end
end