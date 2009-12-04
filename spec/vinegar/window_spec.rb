#!/usr/bin/env macruby
require File.expand_path('../spec_helper', __FILE__)

describe "Rucola::Vinegar::Window" do
  before do
    @window = Window.new
  end
  
  it "should initialize a NSWindow instance" do
    @window.object.should.be.instance_of NSWindow
  end
  
  it "should initialize with sensible dimensions defaults" do
    @window.width.should == 480
    @window.height.should == 270
    # TODO: can't get the origin in a test
    @window.x.should == 0
    @window.x.should == 0
  end
  
  it "should initialize with the given dimensions" do
    @window = Window.new(111, 222, 200, 300)
    
    @window.width.should == 200
    @window.height.should == 300
    # TODO: can't get the origin in a test
    @window.x.should == 0
    @window.x.should == 0
  end
  
  it "should initialize with sensible style defaults" do
    @window.object.styleMask.should == NSTitledWindowMask |
                                       NSClosableWindowMask |
                                       NSMiniaturizableWindowMask |
                                       NSResizableWindowMask
  end
  
  it "should initialize with sensible backing store defaults" do
    @window.object.backingType.should == NSBackingStoreBuffered
  end
end

describe "A Rucola::Vinegar::Window instance" do
  before do
    @window = Window.new
  end
  
  it "should show when requested" do
    @window.should.not.be.visible
    @window.show
    @window.should.be.visible
  end
  
  it "should return the subviews" do
    view = NSView.alloc.init
    @window.object.contentView.addSubview(view)
    @window.views.should == [view]
    @window.to_a.should == [view]
  end
  
  it "should add the `object' of a view object to its content view" do
    button1 = Button.new
    @window << button1
    @window.views.should == [button1.object]
    
    button2 = Button.new
    @window.push(button2)
    @window.views.should == [button1.object, button2.object]
  end
end