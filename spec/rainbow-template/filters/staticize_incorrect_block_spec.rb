require 'spec_helper'

describe "A staticize incorrect block filter" do
  before do
    @filter = Rainbow::Template::StaticizeIncorrectBlock.new :otag => "{",
                                                             :ctag => "}"
    @filter.grammer = { "block:Posts" => [ "block:Title" ] }
  end

  it "should be able to staticize a block" do
    staticized_block = @filter.staticize_block([:block, "block:Posts", [:multi, [:static, "test"],
                                                                                [:close_block, "block:Posts"]]])

    staticized_block.must_equal [:multi, [:static, "{block:Posts}"], [:static, "test"], [:static, "{/block:Posts}"]]
  end

  it "should be able to staticize incorrect nested block structure" do
    sexp = [:multi, [:block, "block:Posts", [:multi, [:block, "block:Posts", [:multi, [:static, "test"],
                                                                                      [:variable, "x"],
                                                                                      [:close_block, "block:Posts"]]],
                                                     [:close_block, "block:Posts"]]]]
    correct_sexp = [:multi, [:block, "block:Posts", [:multi, [:multi, [:static, "{block:Posts}"],
                                                                      [:static, "test"],
                                                                      [:static, "{x}"],
                                                                      [:static, "{/block:Posts}"]],
                                                             [:close_block, "block:Posts"]]]]
    @filter.filter(sexp).must_equal correct_sexp
  end

  it "should not modify correct nested block structure" do
    sexp = [:multi, [:block, "block:Posts", [:multi, [:block, "block:Title", [:multi, [:static, "This is title"],
                                                                                      [:close_block, "block:Title"]]],
                                                     [:close_block, "block:Posts"]]]]

    @filter.filter(sexp).must_equal sexp
  end
end
