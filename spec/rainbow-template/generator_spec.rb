require 'spec_helper'

describe Rainbow::Template::Generator do
  describe "A generator" do
    before do
      @generator = Rainbow::Template::Generator.new :otag => "{",
                                                    :ctag => "}"
    end

    it "should be able to compile a static expression to string" do
      sexp = [:static, "Hello World"]
      ctx = {}
      @generator.compile(sexp, ctx).must_equal "Hello World"
    end

    it "should be able to compile a variable to string" do
      sexp = [:variable, "Title"]
      ctx = {"Title" => "Hello World"}
      @generator.compile(sexp, ctx).must_equal "Hello World"
    end

    it "should be able to compile multi expressions" do
      sexp = [:multi, [:static, "Hello "],
                      [:variable, "Title"]]
      ctx = {"Title" => "World"}
      @generator.compile(sexp, ctx).must_equal "Hello World"
    end

    it "should be able to handle undefined variable" do
      sexp = [:multi, [:static, "Hello "],
                      [:variable, "Title"]]
      ctx = {}
      @generator.compile(sexp, ctx).must_equal "Hello {Title}"
    end

    it "should be able to compile block expressions with true/false" do
      sexp = [:multi, [:static, "out of block "],
                      [:block, "block:Text",[:multi, [:static, "in block"],
                                                     [:close_block, "block:Text"]]]]

      @generator.compile(sexp, {}).must_equal "out of block "
      @generator.compile(sexp, {"block:Text" => true }).must_equal "out of block in block"
      @generator.compile(sexp, {"block:Text" => false}).must_equal "out of block "
    end

    it "should be able to compile block with scoped variables" do
      sexp = [:multi, [:static, "out of block "],
                      [:block, "block:Text",[:multi, [:variable, "Body"],
                                                     [:close_block, "block:Text"]]]]
      @generator.compile(sexp, {}).must_equal "out of block "
      @generator.compile(sexp, {"block:Text" => { "Body" => "hello world" }} ).must_equal "out of block hello world"
    end

    it "should be able to compile collection block" do
      sexp = [:multi, [:block, "block:Posts", [:multi, [:static, "block"],
                                                       [:close_block, "block:Posts"]]]]
      @generator.compile(sexp, {}).must_equal ""
      @generator.compile(sexp, {"block:Posts" => [{ "Body" => "b1" },
                                                  { "Body" => "b2" },
                                                  { "Body" => "b3" }]}).must_equal "block"*3
    end

    it "should be able to compile iterator block with variables" do
      sexp = [:multi, [:block, "block:Posts", [:multi, [:variable, "Body"],
                                                       [:close_block, "block:Posts"]]]]
      @generator.compile(sexp, {}).must_equal ""
      @generator.compile(sexp, {"block:Posts" => [{ "Body" => "b1" },
                                                  { "Body" => "b2" },
                                                  { "Body" => "b3" }]}).must_equal "b1b2b3"
    end

    it "should be able to compile nested block" do
      sexp = [:multi, [:block, "block:Posts", [:multi, [:block, "block:Text", [:multi, [:variable, "Body"],
                                                                                       [:close_block, "block:Text"]]],
                                                       [:close_block, "block:Posts"]]]]
      @generator.compile(sexp, {}).must_equal ""
      @generator.compile(sexp, {"block:Posts" => [{"block:Text" => { "Body" => "Hello World" }}]}).must_equal "Hello World"
      @generator.compile(sexp, {"block:Posts" => [{"block:Text" => { "Body" => "Hello World" }},
                                                  {"block:Text" => { "Body" => "Hello World2" }}]}).must_equal "Hello WorldHello World2"
    end

    it "should be able to handle incorrect nested block" do
      sexp = [:multi, [:block, "block:Posts", [:multi, [:block, "block:Posts", [:multi, [:variable, "Body"],
                                                                                        [:close_block, "block:Posts"]]],
                                                       [:close_block, "block:Posts"]]]]

      @generator.compile(sexp, {}).must_equal ""
      @generator.compile(sexp, {"block:Posts" => [{"block:Text" => { "Body" => "Hello World" }}]}).must_equal ""
      @generator.compile(sexp, {"block:Posts" => [{"block:Text" => { "Body" => "Hello World" }},
                                                  {"block:Text" => { "Body" => "Hello World2" }}]}).must_equal ""
    end
  end
end
