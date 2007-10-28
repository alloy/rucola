require "rubygems"
require "test/unit"
require "test/spec"
require "mocha"

require 'rucola/rucola_support/core_ext/string'

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
