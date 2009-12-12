#!/usr/bin/env macruby
require File.expand_path('../spec_helper', __FILE__)

describe "Rucola::Vinegar::Object" do
  it "stores the proxied class in the global mappings" do
    Rucola::Vinegar::PROXY_MAPPINGS[CocoaTestClass].should == VinegarTestObject
  end
  
  it "initializes with an options hash and assign the options to the accessors" do
    o = VinegarTestObject.new(:main_ingredient => "lettuce")
    o.main_ingredient.should == "lettuce"
  end
  
  # TODO: A bug in MacRuby with ordered hashes
  # it "assigns the initialization options in the given order" do
  #   o = VinegarObject.new(:main_ingredient => "lettuce", :total => "bacon")
  #   o.total.should == "lettuce with bacon"
  # end
end

describe "An instance of Rucola::Vinegar::Object, concerning the proxied object" do
  before do
    @object = VinegarTestObject.new
  end
  
  it "instantiates an instance on demand" do
    @object.instance_variable_get(:@object).should == nil
    @object.object.should.be.instance_of CocoaTestClass
  end
  
  it "assigns itself as the proxy object" do
    @object.object.instance_variable_get(:@_vinegar_object).should == @object
  end
end