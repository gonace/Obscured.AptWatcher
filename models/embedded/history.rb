module Obscured
  module AptWatcher
    module Models
      class HistoryLog
        include Mongoid::Document
        include Mongoid::Timestamps
        field :text, type: String
        field :created_by, type: String

        embedded_in :history, polymorphic: true

        def self.make(text, user)
          entity = self.new
          entity.text = text
          entity.created_by = user
          entity
        end
      end
    end
  end
end