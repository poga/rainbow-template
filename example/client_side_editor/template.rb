require 'nokogiri'
require_relative 'meta'

class Template
  attr_reader :ctx, :ctx_editor_tags, :ctx_selector_type, :ctx_editor_selector

  def initialize(filename)
    @document = Nokogiri::HTML.parse(File.read(filename))

    @ctx = {}
    @ctx_editor_tags = []
    @ctx_editor_selector = {}
    @ctx_selector_type = {}

    @document.css("meta").each do |m|
      meta = Meta.new(m.attributes["name"].value, m.attributes["content"].value)

      @ctx_selector_type[meta.path] = meta.type
      @ctx.merge! meta.value_obj
      @ctx_editor_selector.merge! meta.selector_obj
      @ctx_editor_tags << meta.editor_tag
    end
  end
end
