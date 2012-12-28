class Meta
  attr_reader :key, :value, :type, :path, :name, :value_obj, :selector_obj

  def initialize(key, value)
    @value = value
    @key = key

    if @value == "1"
      @value = true
    elsif @value == "0"
      @value = false
    end

    @type, @path = key.split("@")

    parse_path!
  end

  def editor_tag
    case @type
    when "text"
      "#{@name}: <input data-rt=\"#{@editor_id}\" value=\"#{@value}\"></input><br />"
    when "if"
      "#{@name}: <input type=\"checkbox\" data-rt=\"#{@editor_id}\" #{@value ? "checked" : ""}></input><br />"
    when "color"
      "#{@name}: <input data-rt=\"#{@editor_id}\" value=\"#{@value}\"></input><br />"
    else
      "#{@name}: <input data-rt=\"#{@editor_id}\" value=\"#{@value}\"></input><br />"
    end
  end

  private

  def parse_path!
    paths = @path.split("/")
    @name = paths[-1]
    @editor_id = paths.join('-')

    @value_obj = paths.reverse.inject(nil) do |obj, p|
      if obj == nil
        obj = { p => value }
      else
        obj = { p => obj }
      end
    end

    @selector_obj = paths.reverse.inject(nil) do |obj, p|
      if obj == nil
        obj = { p => @editor_id }
      else
        obj = { p => obj }
      end
    end
  end
end
