require File.dirname(__FILE__) + '/test_helper'

class FooBar
  def self.a_original_class_method
  end
end

module Baz
  def a_new_class_method; end
end
FooBar.extend(Baz)

class FooBarSubclass < FooBar
  def self.a_original_class_method_in_a_subclass
  end
end

# Object ext. specs

describe "Object: class methods" do
  it "should return the metaclass of a class" do
    class << FooBar
      self.should.be FooBar.metaclass
    end
  end
  
  it "should return an array of class methods that have been added by extending the class" do
    FooBar.extended_class_methods.should.include 'a_new_class_method'
    FooBar.extended_class_methods.should.not.include 'a_original_class_method'
  end
  
  it "should return an array of all the class methods that were defined in this class without the ones that were defined in superclasses" do
    FooBarSubclass.own_class_methods.should.include 'a_original_class_method_in_a_subclass'
    FooBarSubclass.own_class_methods.should.not.include 'a_original_class_method'
  end
  
  it "should return an array of all the class methods that were defined in only this class, so not from it's superclasses or from extending" do
    FooBar.original_class_methods.should.include 'a_original_class_method'
    FooBar.original_class_methods.should.not.include 'a_new_class_method'
    
    FooBarSubclass.original_class_methods.should.include 'a_original_class_method_in_a_subclass'
    FooBarSubclass.original_class_methods.should.not.include 'a_original_class_method'
    FooBarSubclass.original_class_methods.should.not.include 'a_new_class_method'
  end
end

# String ext. specs

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

describe "String#constantize" do
  it "should return the constant FooBar for string 'foo_bar'" do
    "foo_bar".constantize.should.be FooBar
  end
  
  it "should return the constant FooBar for string 'FooBar'" do
    "FooBar".constantize.should.be FooBar
  end
end

# File ext. specs

describe "File.constantize" do
  it "should return the constant FooBar for file '/some/path/foo_bar.rb'" do
    File.constantize('/some/path/foo_bar.rb').should.be FooBar
  end
  
  it "should return the constant FooBar for file 'foo_bar.rb'" do
    File.constantize('foo_bar.rb').should.be FooBar
  end
end

# Kernel ext. specs

describe "Kernel.logger" do
  it "should return a Rucola Log class instance" do
    Kernel.log.kind_of?(Rucola::Log).should == true
  end
  
  it "should return the same logger instance on multiple calls" do
    Kernel.log.object_id.should == Kernel.log.object_id
  end
end