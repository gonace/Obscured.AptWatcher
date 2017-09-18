module Obscured
  module Helpers
    class Statistics
      def self.fetch(from, to)
        raise Obscured::DomainError.new(:required_field_missing, what: ':from') if from.blank?
        raise Obscured::DomainError.new(:required_field_missing, what: ':to') if to.blank?


      end


      def self.fetch_errors_count(from, to)
        raise Obscured::DomainError.new(:required_field_missing, what: ':from') if from.blank?
        raise Obscured::DomainError.new(:required_field_missing, what: ':to') if to.blank?

        errors_open = Obscured::AptWatcher::Models::Error.where(:status => Obscured::Status::OPEN, :created_at.gte => from, :created_at.lte => to).count
        errors_closed = Obscured::AptWatcher::Models::Error.where(:status => Obscured::Status::CLOSED, :created_at.gte => from, :created_at.lte => to).count

        e_open = 0
        e_closed = 0
        if errors_open > 0 or errors_closed > 0
          base = 100 / (errors_open + errors_closed).to_d

          if errors_open > 0
            e_open = (base * errors_open).to_i
          end
          if errors_closed > 0
            e_closed = (base * errors_closed).to_i
          end
        else
          e_closed = 100
        end

        return e_open, e_closed
      end
    end
  end
end