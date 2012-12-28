require 'sinatra'
require 'json'
require 'yaml'
require 'nokogiri'
require 'rainbow-template'
require 'pry'
require_relative 'meta'

js_engine = Rainbow::Template::Engine.new :parser => Rainbow::Template::Parser,
                                       :generator => Rainbow::Template::JavascriptGenerator,
                                       :variable_tags => ["Title", "Header", "title", "Color", "moo"],
                                       :block_tags => ["Post", "Show", "Nested"].map { |x| "block:#{x}" }
html_engine = Rainbow::Template::Engine.new :parser => Rainbow::Template::Parser,
                                       :generator => Rainbow::Template::StringGenerator,
                                       :variable_tags => ["JsTemplate", "DefaultCtx", "DefaultCtxSelectors", "CtxPathType","EditorUIs", "seedData"],
                                       :block_tags => []

t = Nokogiri::HTML.parse(File.read("template.html"))

default_ctx = {}
# jquery selectors to get ctx's corresponding editor value
default_ctx_selectors = {}
ctx_path_type = {}
editor_tags = []

t.css("meta").each do |m|
  key = m.attributes["name"].value
  value = m.attributes["content"].value

  meta = Meta.new(key, value)
  ctx_path_type[meta.path] = meta.type

  default_ctx.merge!(meta.value_obj)

  default_ctx_selectors.merge!(meta.selector_obj)

  editor_tags << meta.editor_tag
end

# Some seed datas ( not modifiable)
seed_datas = YAML.load_file("seed_data.yaml")
default_ctx.merge!(seed_datas)

get '/' do
  html_engine.call(File.read("index.html"), { "JsTemplate" => js_engine.call(File.read("template.html"), default_ctx),
                                              "DefaultCtxSelectors" => default_ctx_selectors.to_json,
                                              "CtxPathType" => ctx_path_type.to_json,
                                              "EditorUIs" => editor_tags.join,
                                              "seedData" => seed_datas.to_json})
end
