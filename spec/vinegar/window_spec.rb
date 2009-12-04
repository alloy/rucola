#!/usr/bin/env macruby
require File.expand_path('../../spec_helper', __FILE__)
require 'rucola/vinegar'

describe "Rucola::Vinegar::Window" do
  before do
    @window = Rucola::Vinegar::Window.new
  end
  
  it "should have a NSWindow instance" do
    @window.object.should.be.instance_of NSWindow
  end
  
  it "should initialize with sensible dimensions defaults" do
    @window.width.should == 600
    @window.height.should == 450
    
    # we can't get the origin in a test
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