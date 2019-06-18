module Obscured
  module AptWatcher
    module Entities
      module Ajax
        class Response
          attr_accessor :data
          attr_accessor :success

          def initialize(data=nil, success=true)
            @data = data
            @success = success
          end
        end

        class Error < Response
          attr_accessor :message
          attr_accessor :type

          def initialize(message, type, success=false, result=nil)
            @message = message
            @type = type
            @success = success
            @result = result
          end
        end
      end
    end
  end
end