#!/usr/bin/env macruby

require File.expand_path('../../test_helper', __FILE__)

describe "Kernel.log" do
  it "should return a Rucola Log class instance" do
    Kernel.log.kind_of?(Rucola::Log).should == true
  end
  
  it "should return the same logger instance on multiple calls" do
    Kernel.log.object_id.should == Kernel.log.object_id
  end
end