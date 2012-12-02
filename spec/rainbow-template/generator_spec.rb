# encoding: UTF-8
require 'spec_helper'

describe Rainbow::Template::Generator do
  describe "When initializing a generator" do
    it "should be able to choose different output type" do
      @generator = Rainbow::Template::Generator.new :output => "string"
      @generator = Rainbow::Template::Generator.new :output => "javascript"
    end
  end
end
