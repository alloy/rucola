#!/usr/bin/env macruby
require File.expand_path('../spec_helper', __FILE__)

describe "Rucola::Vinegar::Button" do
  before do
    @button = Button.new { :clicked }
  end
  
  it "initializes a NSButton instance" do
    @button.object.should.be.instance_of NSButton
  end
  
  it "initializes with sensible dimension defaults" do
    @button.x.should == 14
    @button.y.should == 14
    @button.width.should == 96
    @button.height.should == 32
  end
  
  it "initializes with sensible style defaults" do
    @button.object.bezelStyle.should == NSRoundedBezelStyle
  end
  
  it "stores the block given to ::new" do
    @button.action.call.should == :clicked
  end
end

describe "A Rucola::Vinegar::Button instance" do
  before do
    @button = Button.new { |b| [:clicked, b] }
  end
  
  it "assigns the frame" do
    @button.frame = [28, 28, 69, 23]
    
    @button.x.should == 28
    @button.y.should == 28
    @button.width.should == 69
    @button.height.should == 23
  end
  
  it "calls the action block, with the button, when a button is clicked" do
    target, action = @button.object.target, @button.object.action
    target.send(action, @button).should == [:clicked, @button]
  end
  
  it "simulates a click" do
    @button.click.should == [:clicked, @button]
  end
  
  it "accepts an action block" do
    expected = nil
    @button.action = lambda { |b| expected = [:reddish, b] }
    @button.click
    expected.should == [:reddish, @button]
  end
end