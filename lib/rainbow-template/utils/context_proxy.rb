# A context proxy is a hash which every value is either a context proxy
# or a helper proxy
#
# ex.
# { :blog => { :title => HelperProxy.new('r_blog("title")'),
#              :url => HelperProxy.new('r_blog("url")') } }
module Rainbow
  module Template
    class ContextProxy
      def initialize(context_hash, bind)
        @context = context_hash
        @binding = bind
      end


      def [](key)
        if @context[key].is_a? HelperProxy
          return @context[key].call(@binding)
        elsif @context[key].is_a? String
          return HelperProxy.new(@context[key]).call(@binding)
        elsif @context[key].is_a? Hash
          return ContextProxy.new @context[key], @binding
        elsif @context[key].is_a? Array
          return @context[key].map { |c| ContextProxy.new(c, @binding) }
        else
          raise "ERROR: #{key}, #{@context[key]}"
        end
      end
    end
  end
end
