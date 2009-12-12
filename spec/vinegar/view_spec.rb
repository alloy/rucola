#!/usr/bin/env macruby
require File.expand_path('../spec_helper', __FILE__)

class TestView < Rucola::Vinegar::View
  proxy_for NSView
end

describe "An instance of Rucola::Vinegar::View" do
  before do
    @proxy = TestView.new
  end
  
  it "returns the view object, which is normally the object" do
    @proxy.send(:view).should == @proxy.object
  end
  
  it "returns its frame" do
    @proxy.frame.should == @proxy.object.frame.to_a
  end
  
  it "assigns the view's dimensions" do
    @proxy.frame = [1,2,3,4]
    @proxy.frame.should == [1,2,3,4]
  end
  
  it "provides shortcuts for its dimensions" do
    @proxy.frame = [1,2,3,4]
    
    @proxy.x.should == 1
    @proxy.y.should == 2
    @proxy.width.should == 3
    @proxy.height.should == 4
  end
  
  it "should return the subviews' proxies" do
    other = TestView.new
    @proxy.object.addSubview(other.object)
    @proxy.views.should == [other]
    @proxy.to_a.should == [other]
  end
  
  it "should add the `object' of a view object as a subview" do
    button1 = Button.new
    @proxy << button1
    @proxy.views.should == [button1]
    
    button2 = Button.new
    @proxy.push(button2)
    @proxy.views.should == [button1, button2]
  end
end