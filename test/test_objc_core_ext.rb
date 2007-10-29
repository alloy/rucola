require "rubygems"
require "test/unit"
require "test/spec"
require "mocha"
require 'osx/cocoa'

require "rucola/rucola_support"

# FIXME: Actually these are not only objc_core_ext tests but also initialize_hooks tests...

class FooAfterHook < Rucola::RCController; end

describe 'A RCController subclass with Rucola initialize hooks' do
  
  it "should register rucola initialization hooks" do
    hook = Proc.new { 'foo' }
    FooAfterHook._rucola_register_initialize_hook(hook)
    hooks = FooAfterHook.instance_variable_get(:@_rucola_initialize_hooks)
    hooks.should.include hook
  end
  
  it "should run the hooks after initialization" do
    hook = Proc.new { FooAfterHook.some_class_method }
    FooAfterHook._rucola_register_initialize_hook(hook)
    FooAfterHook.expects(:some_class_method).once
    FooAfterHook.alloc.init
  end
end

class Rucola::RCMockClass < OSX::NSObject; end
class BarAfterHook < Rucola::RCMockClass; end

class NotSubClassOfRC < OSX::NSObject; end

describe "NSObject default mixins" do
  it "should automatically mixin the Rucola initialize hooks if it's a subclass of a class that starts with 'Rucola::RC'" do
    BarAfterHook.methods.should.include '_rucola_register_initialize_hook'
  end
  
  it "should not mixin the initialize hooks if it's a subclass of a class that starts with anything else but 'Rucola::RC'" do
    NotSubClassOfRC.methods.should.not.include '_rucola_register_initialize_hook'
  end
end