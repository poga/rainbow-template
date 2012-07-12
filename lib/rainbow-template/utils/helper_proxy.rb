# DEPRECATED
module Rainbow
  module Template
    class HelperProxy
      def initialize(str)
        @str = str
      end

      def call(bind)
        result = eval(@str, bind)
        # block helper
        if result.is_a? Array
          return result.map { |c| ContextProxy.new(c, bind) }
        else
          return result
        end
      end
    end
  end
end
