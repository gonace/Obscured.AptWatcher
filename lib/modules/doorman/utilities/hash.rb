module Obscured
  module Doorman
    class ConfigurationHash < Hash
      include HashRecursiveMerge

      def method_missing(meth, *args, &block)
        key?(meth) ? self[meth] : super
      end
    end
  end
end