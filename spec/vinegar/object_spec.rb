#!/usr/bin/env macruby
require File.expand_path('../spec_helper', __FILE__)

describe "Rucola::Vinegar::Object" do
  it "stores the proxied class in the global mappings" do
    Rucola::Vinegar::PROXY_MAPPINGS[CocoaTestClass].should == VinegarTestObject
  end
  
  it "initializes with an options hash and assign the options to the accessors" do
    proxy = VinegarTestObject.new(:main_ingredient => "lettuce")
    proxy.main_ingredient.should == "lettuce"
  end
  
  # TODO: A bug in MacRuby with ordered hashes
  # it "assigns the initialization options in the given order" do
  #   o = VinegarObject.new(:main_ingredient => "lettuce", :total => "bacon")
  #   o.total.should == "lettuce with bacon"
  # end
  
  it "initializes with a explicit proxied object" do
    object = Object.new
    proxy = VinegarTestObject.new(:object => object)
    proxy.object.should == object
  end
  
  it "calls an object initialization method once to allow setup on the object" do
    proxy = VinegarTestObject.new
    def proxy.init_object
      super
      @counter ||= 1
      @object = @counter
      @counter += 1
    end
    
    proxy.object.should == 1
    proxy.object.should == 1
  end
end

describe "An instance of Rucola::Vinegar::Object, concerning the proxied object" do
  before do
    @proxy = VinegarTestObject.new
  end
  
  it "instantiates an instance on demand" do
    @proxy.instance_variable_get(:@object).should == nil
    @proxy.object.should.be.instance_of CocoaTestClass
  end
  
  it "assigns itself as the proxy object" do
    @proxy.object.instance_variable_get(:@_vinegar_object).should == @proxy
  end
end