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
end