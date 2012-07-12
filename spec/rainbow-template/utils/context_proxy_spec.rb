require "spec_helper"

describe "a context proxy" do
  before do
    def foo(bar)
      return "bar(#{bar})"
    end

    @proxy = ContextProxy.new({ :foo => { :foo1 => HelperProxy.new("foo(1)"),
                                          :foo2 => HelperProxy.new("foo(2)") }}, binding)
  end

  it "should respond to []" do
    @proxy.must_respond_to :"[]"
  end

  it "should be able to return nested context proxy" do
    @proxy[:foo].must_be_kind_of ContextProxy
  end

  it "should be able to return correct helper value" do
    @proxy[:foo][:foo1].must_equal "bar(1)"
  end
end
