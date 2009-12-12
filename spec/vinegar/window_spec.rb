#!/usr/bin/env macruby
require File.expand_path('../spec_helper', __FILE__)

describe "Rucola::Vinegar::Window" do
  before do
    @window = Window.new
  end
  
  it "initializes a NSWindow instance" do
    @window.object.should.be.instance_of NSWindow
  end
  
  it "initializes with sensible dimension defaults" do
    # TODO: can't get the origin in a test
    # @window.x.should == 100
    # @window.y.should == 100
    @window.width.should == 480
    @window.height.should == 270
  end
  
  it "initializes with sensible style defaults" do
    @window.object.styleMask.should == NSTitledWindowMask |
                                       NSClosableWindowMask |
                                       NSMiniaturizableWindowMask |
                                       NSResizableWindowMask
  end
  
  it "initializes with sensible backing store defaults" do
    @window.object.backingType.should == NSBackingStoreBuffered
  end
end

describe "A Rucola::Vinegar::Window instance" do
  before do
    @window = Window.new
  end
  
  it "returns the contentView as its view" do
    @window.send(:view).should == @window.object.contentView
  end
  
  it "assigns the frame to the contentView" do
    @window.frame = [111, 222, 200, 300]
    
    @window.x.should == 111
    @window.y.should == 222
    @window.width.should == 200
    @window.height.should == 300
  end
  
  it "shows when requested" do
    @window.should.not.be.visible
    @window.show
    @window.should.be.visible
  end
  
  it "adds the `object' of a view object to its content view" do
    button1 = Button.new
    @window << button1
    @window.views.should == [button1]
    
    button2 = Button.new
    @window.push(button2)
    @window.views.should == [button1, button2]
  end
end