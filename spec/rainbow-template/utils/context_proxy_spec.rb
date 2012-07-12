require "spec_helper"

describe "a context proxy" do
  before do
    def foo(bar)
      return "bar(#{bar})"
    end

    @proxy = Rainbow::Template::ContextProxy.new({ :foo => { :foo1 => Rainbow::Template::HelperProxy.new("foo(1)"),
                                                             :foo2 => Rainbow::Template::HelperProxy.new("foo(2)") }}, binding)
  end

  it "should respond to []" do
    @proxy.must_respond_to :"[]"
  end

  it "should be able to return nested context proxy" do
    @proxy[:foo].must_be_kind_of Rainbow::Template::ContextProxy
  end

  it "should be able to return correct helper value" do
    @proxy[:foo][:foo1].must_equal "bar(1)"
  end

  it "should be able to handle string value" do
    proxy = Rainbow::Template::ContextProxy.new( { "x" => "foo(1)"}, binding)
    proxy["x"].must_equal "bar(1)"
  end

  it "should be able to handle when a helper returns an array" do
    def bar
      return [ { "v" => "foo(1)" },
               { "v" => "foo(2)" },
               { "v" => "foo(3)" }]
    end

    proxy = Rainbow::Template::ContextProxy.new( { "block" => "bar" }, binding)
    proxy["block"].must_be_kind_of Array
    proxy["block"][0].must_be_kind_of Rainbow::Template::ContextProxy
  end

  it "should be able to handle nil block" do
    proxy = Rainbow::Template::ContextProxy.new({}, binding)
    proxy["test"].must_equal nil
  end
end
