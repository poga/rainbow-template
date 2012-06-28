require 'spec_helper'

describe Rainbow::Template::Parser do
  describe "A parser" do
    before do
      @parser = Rainbow::Template::Parser.new
    end

    it "should response to :call" do
      @parser.must_respond_to :call
    end

    # Simple tags
    it "should be able to parse a variable tag" do
      template = "{Title}"
      sexp = @parser.call(template)
      sexp.must_equal [:multi, [ :variable, "Title" ]]
    end

    it "should be able to parse a basic document" do
      template = "<p></p>"
      sexp = @parser.call(template)
      sexp.must_equal [:multi, [:static, "<p></p>"]]
    end

    it "should be able to parse a variable tag with indent" do
      template = "    {Title}"
      sexp = @parser.call(template)
      sexp.must_equal [:multi, [:static, '    '],
                               [:variable, "Title"]]
    end

    it "should be able to parse a template with spaces between tags" do
      template = "  {Title}  {Title}"
      sexp = @parser.call(template)
      sexp.must_equal [:multi, [:static, '  '],
                               [:variable, "Title"],
                               [:static, '  '],
                               [:variable, "Title"]]
    end

    it "should be able to parse a template with multiple different tags" do
      template = "  {Title}{Description}"
      sexp = @parser.call(template)
      sexp.must_equal [:multi, [:static, '  '],
                               [:variable, "Title"],
                               [:variable, "Description"]]

    end

    it "should be able to parse a template with multiple different tags" do
      template = "  {Title}  {Description}"
      sexp = @parser.call(template)
      sexp.must_equal [:multi, [:static, '  '],
                               [:variable, "Title"],
                               [:static, '  '],
                               [:variable, "Description"]]

    end
    
    it "should be able to parse a template with html tags" do
      template = "<html>{Title}<body>test1234{Description}</body>"
      sexp = @parser.call(template)
      sexp.must_equal [:multi, [:static, "<html>"],
                               [:variable, "Title"],
                               [:static, "<body>test1234"],
                               [:variable, "Description"],
                               [:static, "</body>"]]
    end

    it "should be able to deal with unknown variable" do
      template = "{Unknown}"
      sexp = @parser.call(template)
      sexp.must_equal [:multi, [:static, "{Unknown}"]]
    end

    it "should be able to deal with mixed unknown and known variables" do
      template = "{Unknown}{Title}"
      sexp = @parser.call(template)
      sexp.must_equal [:multi, [:static, "{Unknown}"],
                               [:variable, "Title"] ]
    end

    it "should be able to parse a template with block" do
      template = "<html>{block:Posts}<h2>{Title}</h2><p>{Body}</p>{/block:Posts}"
      sexp = @parser.call(template)
      sexp.must_equal [:multi, [:static, "<html>"],
                               [:block, "block:Posts", [:multi, [:static, "<h2>"],
                                                                [:variable, "Title"],
                                                                [:static, "</h2><p>"],
                                                                [:static, "{Body}"],
                                                                [:static, "</p>"],
                                                                [:close_block, "block:Posts"]]]]
    end

    it "should be able to parse a simplest block" do
      template = "{block:Posts}{/block:Posts}"
      sexp = @parser.call(template)
      sexp.must_equal [:multi, [:block, "block:Posts", [:multi, [:close_block, "block:Posts"]]]]
    end

    it "should be able to parse nested block" do
      template = "{block:Posts}{block:Title}{/block:Title}{/block:Posts}"
      sexp = @parser.call(template)
      sexp.must_equal [:multi, [:block, "block:Posts", [:multi, [:block, "block:Title", [:multi, [:close_block, "block:Title"]]],
                                                                [:close_block, "block:Posts"]]]]
    end
  end
end

