# When a sexp with grammer-incorrect nested block in created
# We have to make the nested block sexp into static segment
#
# ex. [:multi, [:block, "block:Posts", [:multi, [:block, "block:Posts", [:multi, [:close_block, "block:Posts"]]],
#                                               [:close_block, "block:Posts"]]]]
#     is incorrect because a Posts block can't nested again with another Posts block
# 
# Therefore, it should be filtered into
# [:multi, [:block, "block:Posts", [:multi, [:static, "{block:Posts}{/block:Posts}"],
#                                           [:close_block, "block:Posts"]]]]
#
# Hence, The incorrect nested block will be shown in the generated result, providing some debug information
module Rainbow
  module Template
    class StaticizeIncorrectBlockHierarchy
      attr_accessor :grammer
      attr_reader :options

      def initialize(options = {})
        @options = options
      end

      def filter(exp, parent_block = nil)
        case exp.first
        when :multi
          [:multi] + exp[1..-1].map { |e| filter(e, parent_block) }
        when :static
          exp
        when :variable
          exp
        when :block
          if !parent_block.nil?
            if !grammer[parent_block].include?(exp[1])
              staticize(exp)
            elsif grammer[parent_block].nil?
              exp
            elsif grammer[parent_block].include?(exp[1])
              exp
            end
          else
            [:block, exp[1]] + [filter(exp[2], exp[1])]
          end
        when :close_block
          exp
        end
      end

      def staticize(exp)
        case exp.first
        when :multi
          [:multi] + exp[1..-1].map { |e| staticize(e) }
        when :variable
          staticize_variable(exp)
        when :static
          staticize_static(exp)
        when :block
          staticize_block(exp)
        when :close_block
          [:static, "#{options[:otag]}/#{exp[1]}#{options[:ctag]}"]
        end
      end

      def staticize_variable(exp)
        [:static, "#{@options[:otag]}#{exp[1]}#{@options[:ctag]}"]
      end

      def staticize_block(block_exp)
        block_name = block_exp[1]
        block_childs = block_exp[2]
        staticize = [:multi]
        staticize << [:static, "#{options[:otag]}#{block_name}#{options[:ctag]}" ]

        block_multi_exp = block_exp[2]
        block_multi_exp[1..-1].each do |e|
          staticize << staticize(e)
        end

        #staticize << [:static, "#{options[:otag]}/#{block_name}#{options[:ctag]}"]
        return staticize
      end

      def staticize_static(exp)
        return exp
      end
    end
  end
end
