# encoding: UTF-8
require 'spec_helper'
require 'v8'
require 'json'

describe Rainbow::Template::JavascriptGenerator do
  describe "A javascript generator" do
    before do
      @generator = Rainbow::Template::JavascriptGenerator.new

      @js_ctx = V8::Context.new
      # Compiled javascript template depends on underscore.js
      @js_ctx.load("ext/underscore-min.js")

      def js_eval(ctx, js)
        return @js_ctx.eval("#{js}(#{ctx.to_json})")
      end
    end

    it "should be able to compile a static expression to string" do
      sexp = [:static, "Hello World"]
      ctx = {}
      js_eval(ctx, @generator.compile(sexp, ctx)).must_equal "Hello World"
    end

    it "should be able to compile a variable to string" do
      sexp = [:variable, "Title"]
      ctx = {"Title" => "Hello World"}

      js_eval(ctx, @generator.compile(sexp, ctx)).must_equal "Hello World"
    end

    it "should be able to compile multi expressions" do
      sexp = [:multi, [:static, "Hello "],
                      [:variable, "Title"]]
      ctx = {"Title" => "World"}

      js_eval(ctx, @generator.compile(sexp, ctx)).must_equal "Hello World"
    end

    it "should be able to handle undefined variable" do
      sexp = [:multi, [:static, "Hello "],
                      [:variable, "Title"]]
      ctx = {}

      js_eval(ctx, @generator.compile(sexp, ctx)).must_equal "Hello {Title}"
    end


    it "should be able to compile block expressions with true/false" do
      sexp = [:multi, [:static, "out of block "],
                      [:block, "block:Text",[:multi, [:static, "in block"],
                                                     [:close_block, "block:Text"]]]]
      ctx = {"block:Text" => true }

      js_eval({}, @generator.compile(sexp, {})).must_equal "out of block "
      #raise "#{@generator.compile(sexp, ctx)}(#{ctx.to_json})"
      js_eval({"block:Text" => true }, @generator.compile(sexp, {"block:Text" => true })).must_equal "out of block in block"
      js_eval({"block:Text" => false}, @generator.compile(sexp, {"block:Text" => false})).must_equal "out of block "
    end

    it "should be able to compile block with scoped variables" do
      sexp = [:multi, [:static, "out of block "],
                      [:block, "block:Text",[:multi, [:variable, "Body"],
                                                     [:close_block, "block:Text"]]]]
      js_eval({}, @generator.compile(sexp, {})).must_equal "out of block "
      js_eval({"block:Text" => { "Body" => "hello world" }},
               @generator.compile(sexp, {"block:Text" => { "Body" => "hello world" }} )).must_equal "out of block hello world"
    end

    it "should be able to compile block with scoped variable but the variable is nil" do
      sexp = [:multi, [:static, "out of block "],
                      [:block, "block:Text",[:multi, [:variable, "Body"],
                                                     [:close_block, "block:Text"]]]]
      js_eval({"block:Text" => {}},
               @generator.compile(sexp, {"block:Text" => { "Body" => "hello world" }} )).must_equal "out of block {Body}"
    end

    it "should be able to compile block with scoped variables with duplicated name" do
      sexp = [:multi, [:static, "out of block "],
                      [:block, "block:Text",[:multi, [:variable, "Body"],
                                                     [:close_block, "block:Text"]]]]
      ctx = {"Body" => "not this", "block:Text" => { "Body" => "hello world" }}
      js_eval(ctx, @generator.compile(sexp, ctx) ).must_equal "out of block hello world"
    end


    it "should be able to compile block with scoped variables outside of scope" do
      sexp = [:multi, [:static, "out of block "],
                      [:block, "block:Text",[:multi, [:variable, "Body"],
                                                     [:variable, "Title"],
                                                     [:close_block, "block:Text"]]]]
      js_eval({}, @generator.compile(sexp, {})).must_equal "out of block "
      ctx = {"block:Text" => { "Body" => "hello world" }, "Title" => "Foo" }
      js_eval(ctx, @generator.compile(sexp, ctx)).must_equal "out of block hello worldFoo"
    end

    it "should be able to compile collection block" do
      sexp = [:multi, [:block, "block:Posts", [:multi, [:static, "block"],
                                                       [:close_block, "block:Posts"]]]]
      js_eval({}, @generator.compile(sexp, {})).must_equal ""
      ctx = {"block:Posts" => [{ "Body" => "b1" },
                               { "Body" => "b2" },
                               { "Body" => "b3" }]}
      #raise "#{@generator.compile(sexp, ctx)}(#{ctx.to_json})"
      js_eval(ctx, @generator.compile(sexp, ctx)).must_equal "block"*3
    end

    it "should be able to compile iterator block with variables" do
      sexp = [:multi, [:block, "block:Posts", [:multi, [:variable, "Body"],
                                                       [:close_block, "block:Posts"]]]]
      js_eval({}, @generator.compile(sexp, {})).must_equal ""
      ctx = {"block:Posts" => [{ "Body" => "b1" },
                               { "Body" => "b2" },
                               { "Body" => "b3" }]}
      #raise "#{@generator.compile(sexp, ctx)}(#{ctx.to_json})"
      js_eval(ctx, @generator.compile(sexp, ctx) ).must_equal "b1b2b3"
    end

    it "should be able to compile nested block" do
      sexp = [:multi, [:block, "block:Posts", [:multi, [:block, "block:Text", [:multi, [:variable, "Body"],
                                                                                       [:close_block, "block:Text"]]],
                                                       [:close_block, "block:Posts"]]]]
      js_eval({}, @generator.compile(sexp, {})).must_equal ""
      ctx = {"block:Posts" => [{"block:Text" => { "Body" => "Hello World" }}]}
      #raise "#{@generator.compile(sexp, ctx)}(#{ctx.to_json})"
      js_eval(ctx, @generator.compile(sexp, ctx)).must_equal "Hello World"
      ctx = {"block:Posts" => [{"block:Text" => { "Body" => "Hello World" }},
                               {"block:Text" => { "Body" => "Hello World2" }}]}
      js_eval(ctx, @generator.compile(sexp, ctx) ).must_equal "Hello WorldHello World2"
    end

    it "should be able to handle incorrect nested block" do
      sexp = [:multi, [:block, "block:Posts", [:multi, [:block, "block:Posts", [:multi, [:variable, "Body"],
                                                                                        [:close_block, "block:Posts"]]],
                                                       [:close_block, "block:Posts"]]]]

      js_eval({}, @generator.compile(sexp, {})).must_equal ""
      ctx = {"block:Posts" => [{"block:Text" => { "Body" => "Hello World" }}]}
      js_eval(ctx, @generator.compile(sexp, ctx) ).must_equal ""
      ctx = {"block:Posts" => [{"block:Text" => { "Body" => "Hello World" }},
                                                  {"block:Text" => { "Body" => "Hello World2" }}]}
      js_eval(ctx, @generator.compile(sexp, ctx) ).must_equal ""
    end

    it "should be able to handle nil variable" do
      sexp = [:multi, [:variable, "foo"],
                      [:static, "bar"]]
      ctx = { "foo" => nil }
      js_eval(ctx, @generator.compile(sexp, ctx) ).must_equal "bar"
    end

    it "should be able to handle nil block" do
      sexp = [:block, "moo", [:static, "foo"]]
      js_eval({}, @generator.compile(sexp, {})).must_equal ""
    end

    it "should be able to handle utf-8 variable values" do
      sexp = [:variable, "foo"]
      ctx = {"foo" => "中文"}
      js_eval(ctx, @generator.compile(sexp,ctx) ).must_equal "中文"
    end
  end

end

