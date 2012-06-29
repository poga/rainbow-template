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
          if context["#{exp[1]}:visible"] || context[exp[1]]
            block = Block.new( exp[2] )
            block.compile( context[exp[1]] )
          end
        end
      end
  end
  end
end
