module Sinatra
  module Doorman
    class HistoryLog
      include Mongoid::Document
      field :text, type: String
      field :user, type: String
      field :created, type: DateTime, default: -> {DateTime.now}

      embedded_in :history, polymorphic: true

      def self.make(text, user)
        h = self.new
        h.text = text
        h.user =user
        h
      end

      def to_view_model
        {
          :created => self.created,
          :text => self.text,
          :utils => self.user
        }
      end
    end
  end
end