require 'spec_helper'

describe "An Engine" do
  before do
    class Test < Rainbow::Template::Engine
    end
    @template = Test.new :parser => Rainbow::Template::Parser,
                         :generator => Rainbow::Template::StringGenerator,
                         :variable_tags => ["Test"],
                         :block_tags => ["block:Foo"]
  end

  it "should be able to parse a empty template" do
    @template.call("").must_equal ""
  end

  it "should be able to parse a template which contains variable" do
    @template.call("{Test}", { "Test" => "hello" }).must_equal "hello"
  end

  it "should be deal with plain javascript" do
    rt = <<-TEMPLATE
    Rainbow.getLoginStatus( function(response) {
        if (response.status === "logged_in") {
            // Show user's nickname and avatar to header
            var userIcon = document.getElementById("home-icon");
            userIcon.getElementsByTagName("span")[0].getElementsByTagName("img")[0].src = response.user.avatar;
            userIcon.getElementsByTagName("a")[0].innerHTML = response.user.nickname; 
            if (response.user.ownCurrentBlog){
                console.log("The user " + response.user.id + " is logged in and own this blog"); 
                // Hide follow icon
                var homeIcon = document.getElementById("user-follow");
                homeIcon.style.display = "none";
            } else {
                console.log("The user " + response.user.id + " is logged in but doesn't own this blog"); 
                // Hide customize icon
                var customizeIcon = document.getElementById("user-customize");
                customizeIcon.style.display = "none";
            }
        } else {
            console.log("The user isn't logged in to rainbow");
            // Hide customize icon
            var customizeIcon = document.getElementById("user-customize");
            customizeIcon.style.display = "none"; 
            // Maybe still show the follow icon but prompt login when he click it?
        }
    });
    TEMPLATE

    @template.call(rt).must_equal rt
  end

  it "should be able to deal with tags within javascript" do
    rt = <<-TEMPLATE
    Rainbow.getLoginStatus( function(response) {
      {block:Foo}
        if (response.status === "logged_in") {
            // Show user's nickname and avatar to header
            var userIcon = document.getElementById("home-icon");
            userIcon.getElementsByTagName("span")[0].getElementsByTagName("img")[0].src = response.user.avatar;
            userIcon.getElementsByTagName("a")[0].innerHTML = response.user.nickname; 
            if (response.user.ownCurrentBlog){
                console.log("The user " + response.user.id + " is logged in and own this blog"); 
                // Hide follow icon
                var homeIcon = document.getElementById("user-follow");
                homeIcon.style.display = "none";
            } else {
                console.log("The user " + response.user.id + " is logged in but doesn't own this blog"); 
                // Hide customize icon
                var customizeIcon = document.getElementById("user-customize");
                customizeIcon.style.display = "none";
            }
        } else {
            console.log("The user isn't logged in to rainbow");
            // Hide customize icon
            var customizeIcon = document.getElementById("user-customize");
            customizeIcon.style.display = "none"; 
            // Maybe still show the follow icon but prompt login when he click it?
        }
      {/block:Foo}
    });
    TEMPLATE

    # NOTICE: 6 spaces in the funcion
    compiled = <<-COMPILED
    Rainbow.getLoginStatus( function(response) {
      
    });
    COMPILED

    @template.call(rt, { "block:Foo" => false }).must_equal compiled
  end
end
