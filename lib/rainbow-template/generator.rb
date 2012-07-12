module Rainbow
  module Template
    class Generator
      def initialize(options = {})
        @options = options
      end

      def compile(exp, context)
        case exp.first
        when :multi
          # exp[0] = :multi
          # exp[1..-1] == array of S-expressions
          exp[1..-1].map { |e| compile(e, context) }.join
        when :static
          # exp[0] = :static
          # exp[1] = static string
          exp[1]
        when :variable
          # exp[0] = :variable
          # exp[1] = variable name
          if !context.has_key? exp[1]
            "#{otag}#{exp[1]}#{ctag}"
          else
            context[exp[1]].to_s
          end
        when :block
          # exp[0] = :block
          # exp[1] = block name
          # exp[2] = multi block
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
          else
            # Do nothing if the block variable does not exist
          end
        end
      end

      def otag
        @otag ||= "{"
      end

      def ctag
        @ctag ||= "}"
      end

      alias call compile

    end
  end
end
