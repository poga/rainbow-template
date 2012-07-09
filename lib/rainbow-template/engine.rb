module Rainbow
  module Template
    # An engine is a chain of compilers,
    # which often includes a parser, some filters and a generator
    class Engine

      def initialize(options)
        @parser = options[:parser]
        @generator = options[:generator]
        @variable_tags = options[:variable_tags]
        @block_tags = options[:block_tags]
      end

      def call(str, context = {})
        p = @parser.new
        p.variable_tags = @variable_tags
        p.block_tags = @block_tags
        sexp = p.call(str)
        return @generator.new.call(sexp, context)
      end

    end
  end

end
