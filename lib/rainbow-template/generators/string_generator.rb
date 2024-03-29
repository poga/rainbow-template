module Rainbow
  module Template
    class StringGenerator
      def initialize(options = {})
        @options = options
      end

      def compile(exp, context)
        context = context.clone
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
          variable_lookup(context, exp[1])
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
              # add a pointer to parent-level context,
              # so we can preform variable lookup recursively up to root level
              nest_ctx = context[exp[1]].merge({ :parentContext => single_level_context(context)})
              block = Block.new( exp[2], nest_ctx  )
              block.compile
            end
          else
            "" # Do nothing if the block variable does not exist
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

      private

      def single_level_context(ctx)
        return ctx.delete_if { |k,v| v.is_a? Hash }
      end

      def variable_lookup(ctx, key)
        if ctx.has_key? key
          ctx[key].to_s
        elsif ctx.has_key? :parentContext
          variable_lookup( ctx[:parentContext], key)
        else
          "#{otag}#{key}#{ctag}"
        end
      end

    end
  end
end
