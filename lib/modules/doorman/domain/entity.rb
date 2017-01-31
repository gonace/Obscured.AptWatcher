module Sinatra
  module Doorman
    # provides simple tracking to entities by adding fields for storing dates for creating/updating entities
    # as well as setting username for updates
    module TrackedEntity
      def self.included(base)
        base.field :created, type: DateTime, default: -> {DateTime.now}
        base.field :created_by, type: String
        base.field :updated, type: DateTime
        base.field :updated_by, type: String
        base.embeds_many :history_logs, as: :history
        base.before_save :set_entity_updated

        @base_klass = base
      end

      # @todo set "current user" as the user updating the entity
      # @todo maybe remove callback in favour of observer
      def set_entity_updated
        if self.created.nil?
        else
          self.updated = DateTime.now
        end
      end

      def add_property_change_log(property_name, old_value, new_value)
        self.add_history_log('Changed %s from [%s] to [%s]' % [property_name, old_value, new_value])
      end

      def add_history_log(text, user='system')
        if self.history_logs.nil?
          self.history_logs = []
        end

        log = HistoryLog.make(text, user)
        self.history_logs << log
      end
    end
  end
end