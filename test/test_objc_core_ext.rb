require "rubygems"
require "test/unit"
require "test/spec"
require "mocha"
require 'osx/cocoa'

require "rucola/rucola_support/objc_core_ext/nsobject"

class FooAfterHook < OSX::NSObject; end

describe 'A NSObject subclass with Rucola after initialize hooks' do
  
  it "should register rucola after initialization hooks" do
    hook = Proc.new { 'foo' }
    FooAfterHook._rucola_register_initialize_hook(hook)
    hooks = FooAfterHook.instance_variable_get(:@_rucola_initialize_hooks)
    hooks.first.should.be hook
  end
  
  it "should run the hooks after initialization" do
    hook = Proc.new { FooAfterHook.some_class_method }
    FooAfterHook._rucola_register_initialize_hook(hook)
    FooAfterHook.expects(:some_class_method).once
    FooAfterHook.alloc.init
  end
end
