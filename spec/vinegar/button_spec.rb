#!/usr/bin/env macruby
require File.expand_path('../spec_helper', __FILE__)

describe "Rucola::Vinegar::Button" do
  before do
    @button = Button.new { :clicked }
  end
  
  it "should initialize a NSButton instance" do
    @button.object.should.be.instance_of NSButton
  end
  
  it "should initialize with sensible dimensions defaults" do
    @button.x.should == 14
    @button.y.should == 14
    @button.width.should == 96
    @button.height.should == 32
  end
  
  it "should initialize with the given dimensions" do
    @button = Button.new(28, 28, 69, 23)
    @button.x.should == 28
    @button.y.should == 28
    @button.width.should == 69
    @button.height.should == 23
  end
  
  it "should store the block given to ::new" do
    @button.action.call.should == :clicked
  end
end

describe "A Rucola::Vinegar::Button instance" do
  before do
    @button = Button.new { |b| [:clicked, b] }
  end
  
  it "should call the action block, with the button, when a button is clicked" do
    target, action = @button.object.target, @button.object.action
    target.send(action, @button).should == [:clicked, @button]
  end
  
  it "should simulate a click" do
    @button.click.should == [:clicked, @button]
  end
  
  it "should accept an action block" do
    expected = nil
    @button.action = lambda { |b| expected = [:reddish, b] }
    @button.click
    expected.should == [:reddish, @button]
  end
end