require "rubygems"
require "test/unit"
require "test/spec"
require "mocha"
require 'osx/cocoa'

require 'rucola/rucola_support/acts_as'

class FooAct < OSX::NSObject
  def self.some_stub_class_method; end
end

module Rucola::ActsAs::FooBar
  def some_new_instance_method; end
end

describe 'ActsAs' do
  before do
    Rucola::ActsAs.register_acts_as :foo_bar
  end
  
  it "should register new ActsAs module" do
    FooAct.methods.should.include 'acts_as_foo_bar'
  end
  
  it "should not add any methods before the ActsAs modules is included" do
    FooAct.instance_methods.should.not.include 'some_new_instance_method'
  end
  
  it "should have added the methods of the ActsAs module to the class after it's included" do
    FooAct.acts_as_foo_bar
    FooAct.instance_methods.should.include 'some_new_instance_method'
  end
  
  it "should not register a after initialization hook if there was no block specified" do
    FooAct.instance_variable_get(:@_rucola_initialize_hooks).should.be.nil
  end
  
  it "should register a after initialization hook if a block is specified and call that block after initialization" do
    FooAct.expects(:some_stub_class_method)
    
    hook = Proc.new { FooAct.some_stub_class_method }
    Rucola::ActsAs.register_acts_as :foo_bar, &hook
    
    FooAct.acts_as_foo_bar
    FooAct.instance_variable_get(:@_rucola_initialize_hooks).first.should.be hook
    FooAct.alloc.init
  end
  
  it "should include the methods from the module in the class" do
    FooAct.acts_as_foo_bar
    FooAct.alloc.init.methods.should.include 'some_new_instance_method'
  end
end
