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
          if context[exp[1]].nil?
            "#{@options[:otag]}#{exp[1]}#{@options[:ctag]}"
          else
            context[exp[1]]
          end
        when :block
          if context[exp[1]]
            if context[exp[1]] == true
              block = Block.new( exp[2] )
              block.compile
            elsif context[exp[1]].is_a? Array
              context[exp[1]].map do |ctx|
                block = Block.new( exp[2], ctx )
                block.compile
              end.join
            else
              block = Block.new( exp[2], context[exp[1]]  )
              block.compile
            end
          end
        end
      end

    end
  end
end
