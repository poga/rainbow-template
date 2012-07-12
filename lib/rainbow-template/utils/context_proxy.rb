# A context proxy is a hash which every value is either a context proxy
# or a helper proxy
#
# ex.
# { :blog => { :title => HelperProxy.new('r_blog("title")'),
#              :url => HelperProxy.new('r_blog("url")') } }
class ContextProxy
  def initialize(context_hash, bind)
    @context = context_hash
    @binding = bind
  end


  def [](key)
    if @context[key].is_a? HelperProxy
      return @context[key].call(@binding)
    else
      return ContextProxy.new @context[key], @binding
    end
  end
end
