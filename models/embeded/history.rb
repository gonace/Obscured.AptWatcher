module Obscured
  module AptWatcher
    module Models
      class HistoryLog
        include Mongoid::Document
        field :text, type: String
        field :user, type: String
        field :created_at, type: DateTime, default: -> {DateTime.now}

        embedded_in :history, polymorphic: true

        def self.make(text, user)
          entity = self.new
          entity.text = text
          entity.user = user
          entity
        end
      end
    end
  end
end