module Rainbow
  module Template
    class Generator
      def initialize(options = {})
        @options = options

        case @options[:output]
        when "string"
          @generator = StringGenerator.new
        when "javascript"
          @generator = JavascriptGenerator.new
        else
          @generator = StringGenerator.new
        end
      end

      def compile(exp, context)
        @generator.compile(exp, context)
      end

      alias call compile
    end
  end
end
