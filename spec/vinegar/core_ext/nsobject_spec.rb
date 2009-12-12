#!/usr/bin/env macruby
require File.expand_path('../../spec_helper', __FILE__)

describe "Rucola::Vinegar::CoreExt::NSObject#to_vinegar" do
  it "returns an existing vinegar proxy object" do
    proxy = VinegarTestObject.new
    proxy.object.to_vinegar.should == proxy
  end
  
  it "returns a new proxy object if it has none yet" do
    object = CocoaTestClass.new
    proxy = object.to_vinegar
    proxy.should.be.instance_of VinegarTestObject
    proxy.object.should == object
  end
end