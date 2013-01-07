require 'sinatra'
require 'json'
require 'yaml'
require 'nokogiri'
require 'rainbow-template'
require 'pry'
require_relative 'meta'
require_relative 'template'

js_engine = Rainbow::Template::Engine.new :parser => Rainbow::Template::Parser,
                                       :generator => Rainbow::Template::JavascriptGenerator,
                                       :variable_tags => ["Title", "Header", "title", "Color", "moo"],
                                       :block_tags => ["Post", "Show", "Nested"].map { |x| "block:#{x}" }
html_engine = Rainbow::Template::Engine.new :parser => Rainbow::Template::Parser,
                                       :generator => Rainbow::Template::StringGenerator,
                                       :variable_tags => ["JsTemplate", "DefaultCtx", "DefaultCtxSelectors", "CtxPathType","EditorUIs", "seedData"],
                                       :block_tags => []


template = Template.new("template.html")

# Some seed datas ( not modifiable)
seed_datas = YAML.load_file("seed_data.yaml")
default_ctx = template.ctx.merge(seed_datas)

get '/' do
  html_engine.call(File.read("index.html"), { "JsTemplate" => js_engine.call(File.read("template.html"), default_ctx),
                                              "DefaultCtxSelectors" => template.ctx_editor_selector.to_json,
                                              "CtxPathType" => template.ctx_selector_type.to_json,
                                              "EditorUIs" => template.ctx_editor_tags.join,
                                              "seedData" => seed_datas.to_json})
end
