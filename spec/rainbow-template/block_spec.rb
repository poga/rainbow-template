require 'spec_helper'

describe Rainbow::Template::Block do
  describe "A block" do
    it "should be able to compile a static expression to string" do
      block = Rainbow::Template::Block.new([:static, "Hello World"])
      block.compile.must_equal "Hello World"
    end

    it "should be able to compile a variable to string" do
      block = Rainbow::Template::Block.new([:variable, "Title"],
                                           {"Title" => "Hello World"})
      block.compile.must_equal "Hello World"
    end

    it "should be able to compile multi expressions" do
      block = Rainbow::Template::Block.new([:multi, [:static, "Hello "],
                                                    [:variable, "Title"]],
                                           {"Title" => "World"})
      block.compile.must_equal "Hello World"
    end

    it "should be able to compile block expressions with true/false" do
      block = Rainbow::Template::Block.new([:multi, [:static, "out of block "],
                                                    [:block, "block:Text",[:multi, [:static, "in block"],
                                                                                   [:close_block, "block:Text"]]]],
                                           {"block:Text" => true })

      block.compile.must_equal "out of block in block"
    end

    it "should be able to compile block with scoped variables" do
      block = Rainbow::Template::Block.new([:multi, [:static, "out of block "],
                                                    [:block, "block:Text",[:multi, [:variable, "Body"],
                                                                                   [:close_block, "block:Text"]]]],
                                           {"block:Text" => { "Body" => "hello world" }} )
      block.compile.must_equal "out of block hello world"
    end

    it "should be able to compile iterator block" do
      block = Rainbow::Template::Block.new([:multi, [:block, "block:Posts", [:multi, [:static, "block"],
                                                                                     [:close_block, "block:Posts"]]]],
                                           {"block:Posts" => [{ "Body" => "b1" },
                                                              { "Body" => "b2" },
                                                              { "Body" => "b3" }]})
      block.compile.must_equal "block"*3
    end

    it "should be able to compile iterator block with variables" do
      block = Rainbow::Template::Block.new([:multi, [:block, "block:Posts", [:multi, [:variable, "Body"],
                                                                                     [:close_block, "block:Posts"]]]],
                                           {"block:Posts" => [{ "Body" => "b1" },
                                                              { "Body" => "b2" },
                                                              { "Body" => "b3" }]})
      block.compile.must_equal "b1b2b3"
    end

    it "should be able to compile nested block" do
      sexp = [:multi, [:block, "block:Posts", [:multi, [:block, "block:Text", [:multi, [:variable, "Body"],
                                                                                       [:close_block, "block:Text"]]],
                                                                                       [:close_block, "block:Posts"]]]]
      ctx1 = {"block:Posts" => [{"block:Text" => { "Body" => "Hello World" }}]}
      block = Rainbow::Template::Block.new(sexp, ctx1)
      block.compile.must_equal "Hello World"

      ctx2 = {"block:Posts" => [{"block:Text" => { "Body" => "Hello World" }},
                                {"block:Text" => { "Body" => "Hello World2" }}]}
      block = Rainbow::Template::Block.new(sexp, ctx2)
      block.compile.must_equal "Hello WorldHello World2"
    end
  end
end
