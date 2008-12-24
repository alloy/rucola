#!/usr/local/bin/macruby

require File.expand_path('../../test_helper', __FILE__)

class FooBar; end

describe "File.to_const" do
  it "should return the constant FooBar for file '/some/path/foo_bar.rb'" do
    File.to_const('/some/path/foo_bar.rb').should.be FooBar
  end
  
  it "should return the constant FooBar for file 'foo_bar.rb'" do
    File.to_const('foo_bar.rb').should.be FooBar
  end
end