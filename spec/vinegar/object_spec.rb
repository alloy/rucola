#!/usr/bin/env macruby
require File.expand_path('../spec_helper', __FILE__)

class CocoaTestClass < NSObject
end

class VinegarObject < Rucola::Vinegar::Object
  proxy_for CocoaTestClass
  
  attr_accessor :main_ingredient, :total
  
  def total=(additive)
    @total = "#{main_ingredient} with #{additive}"
  end
end

describe "Rucola::Vinegar::Object, when initializing" do
  it "accepts an options hash and assign the options to the accessors" do
    o = VinegarObject.new(:main_ingredient => "lettuce")
    o.main_ingredient.should == "lettuce"
  end
  
  # TODO: A bug in MacRuby with ordered hashes
  # it "assigns the options in the given order" do
  #   o = VinegarObject.new(:main_ingredient => "lettuce", :total => "bacon")
  #   o.total.should == "lettuce with bacon"
  # end
end

describe "An instance of Rucola::Vinegar::Object" do
  before do
    @object = VinegarObject.new
  end
  
  it "instantiates an instance of the Cocoa class it proxies on demand" do
    @object.instance_variable_get(:@object).should == nil
    @object.object.should.be.instance_of CocoaTestClass
  end
end