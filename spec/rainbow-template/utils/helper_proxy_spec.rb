require 'spec_helper'

describe "A helper proxy" do
  it "can return the return value of proxied function" do
    hp = Rainbow::Template::HelperProxy.new "foo"
    def foo
      return 0
    end

    hp.call( binding ).must_equal 0
  end

  it "can handle block helper" do
    # A block helper is a method which returns an array of hashes
    hp = Rainbow::Template::HelperProxy.new "foo"
    def foo
      return [ { "x" => "bar(0)"},
               { "x" => "bar(1)"}]
    end

    def bar(x)
      x
    end

    hp.call(binding)[0]["x"].must_equal 0
    hp.call(binding)[1]["x"].must_equal 1
  end
end
