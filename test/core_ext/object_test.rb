#!/usr/bin/env macruby

require File.expand_path('../../test_helper', __FILE__)

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

unless_on_macruby do
  describe "Object: class methods" do
    it "should return the metaclass of a class" do
      class << FooBar; self; end.should.be FooBar.metaclass
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
end