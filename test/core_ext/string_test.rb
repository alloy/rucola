#!/usr/local/bin/macruby

require File.expand_path('../../test_helper', __FILE__)

class FooBar; end

describe 'String#camel_case' do
  it "should return foo_bar as FooBar" do
    "foo_bar".camel_case.should == 'FooBar'
  end
  
  it "should return FooBar as FooBar" do
    "FooBar".camel_case.should == 'FooBar'
  end
  
  it "should return foo as Foo" do
    'foo'.camel_case.should == 'Foo'
  end
end

describe "String#to_const" do
  it "should return the constant FooBar for string 'foo_bar'" do
    "foo_bar".to_const.should.be FooBar
  end
  
  it "should return the constant FooBar for string 'FooBar'" do
    "FooBar".to_const.should.be FooBar
  end
end