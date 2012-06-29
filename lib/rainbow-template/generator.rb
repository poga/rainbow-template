module Rainbow
  module Template
    class Generator
      def initialize(options = {})
        @options = options
      end

      def compile(exp, context)
        case exp.first
        when :multi
          exp[1..-1].map { |e| compile(e, context) }.join
        when :static
          exp[1]
        when :variable
          context[exp[1]]
        when :block
          if context[exp[1]]
            block = Block.new( exp[2] )
            if context[exp[1]] == true
              block.compile
            elsif context[exp[1]].is_a? Array
              context[exp[1]].map { |ctx| block.compile(ctx) }.join
            else
              block.compile( context[exp[1]] )
            end
          end
        end
      end
  end
  end
end
