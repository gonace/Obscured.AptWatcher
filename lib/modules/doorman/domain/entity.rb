module Obscured
  module Doorman
    module TrackedEntity
      def self.included(base)
        base.field :created_by, type: String
        base.field :updated_by, type: String
        base.embeds_many :history_logs, as: :history
        base.before_save :set_entity_updated

        @base_klass = base
      end

      def set_entity_updated
        if self.created_at.nil?
        else
          self.updated_at = DateTime.now
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