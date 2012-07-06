module Rainbow
  module Template
    class Block
      attr_reader :source, :context

      def initialize(source, context = {})
        @source = source
        @context = context
      end

      def compile
        Generator.new.compile(@source, context)
      end
    end
  end
end
