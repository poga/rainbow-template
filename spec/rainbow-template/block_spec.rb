require 'spec_helper'

describe Rainbow::Template::Block do
  describe "A block" do
    it "should be able to compile a static expression to string" do
      block = Rainbow::Template::Block.new([:static, "Hello World"])
      block.compile.must_equal "Hello World"
    end

    it "should be able to compile a variable to string" do
      block = Rainbow::Template::Block.new([:variable, "Title"])
      block.compile({"Title" => "Hello World"}).must_equal "Hello World"
    end

    it "should be able to compile multi expressions" do
      block = Rainbow::Template::Block.new([:multi, [:static, "Hello "],
                                                    [:variable, "Title"]])
      block.compile({"Title" => "World"}).must_equal "Hello World"
    end

    it "should be able to compile block expressions with true/false" do
      block = Rainbow::Template::Block.new([:multi, [:static, "out of block "],
                                                    [:block, "block:Text",[:multi, [:static, "in block"],
                                                                                   [:close_block, "block:Text"]]]])

      block.compile( {"block:Text:visible" => false}).must_equal "out of block "
      block.compile( {"block:Text:visible" => true }).must_equal "out of block in block"
    end

    it "should be able to compile block with scoped variables" do
      block = Rainbow::Template::Block.new([:multi, [:static, "out of block "],
                                                    [:block, "block:Text",[:multi, [:variable, "Body"],
                                                                                   [:close_block, "block:Text"]]]])
      block.compile( {"block:Text:visible" => false}).must_equal "out of block "
      block.compile( {"block:Text" => { "Body" => "hello world" }} ).must_equal "out of block hello world"
    end
  end
end
