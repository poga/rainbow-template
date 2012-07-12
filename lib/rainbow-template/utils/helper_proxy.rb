class HelperProxy
  def initialize(str)
    @str = str
  end

  def call(binding)
    return eval(@str, binding)
  end
end
