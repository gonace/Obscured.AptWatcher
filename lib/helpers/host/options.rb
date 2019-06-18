module Obscured
  module AptWatcher
    module Host
      class Options
        attr_accessor :limit
        attr_accessor :skip

        def initialize(args)
          @limit = args[:limit].blank? ? nil : args[:limit]
          @skip = (args[:skip].blank? or args[:skip] == 0) ? nil : args[:skip]
        end


        def to_hash
          query = {}
          query.merge!(:limit => @limit.to_s) unless @limit.blank?
          query.merge!(:skip => @skip.to_s) unless @skip.blank?
          query
        end
        alias to_h to_hash
      end
    end
  end
end