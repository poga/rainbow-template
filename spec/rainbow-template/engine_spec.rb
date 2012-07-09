require 'spec_helper'

describe "An Engine" do
  before do
    class Test < Rainbow::Template::Engine
    end
    @template = Test.new :parser => Rainbow::Template::Parser,
                         :generator => Rainbow::Template::Generator,
                         :variable_tags => ["Test"],
                         :block_tags => []
  end

  it "should be able to parse a empty template" do
    @template.call("").must_equal ""
  end

  it "should be able to parse a template which contains variable" do
    @template.call("{Test}", { "Test" => "hello" }).must_equal "hello"
  end
end
