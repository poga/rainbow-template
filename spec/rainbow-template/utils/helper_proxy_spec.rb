require 'spec_helper'

describe "A helper proxy" do
  it "can return the return value of proxied function" do
    hp = HelperProxy.new "foo"
    def foo
      return 0
    end

    hp.call( binding ).must_equal 0
  end
end
