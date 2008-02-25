require File.dirname(__FILE__) + '/test_helper.rb'

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

describe "NSImage.imageNamed" do
  before do
    @image1 = File.join(Rucola::RCApp.assets_path, 'hot_babe.jpg')
    @image2 = File.join(Rucola::RCApp.assets_path, 'not_so_hot_babe.png')
    Dir.stubs(:glob).with("#{Rucola::RCApp.assets_path}/*.*").returns(['.', '..', @image2, @image1])
  end
  
  it "should find images without in app/assets" do
    OSX::NSImage.any_instance.expects(:initWithContentsOfFile).with(@image1)
    OSX::NSImage.imageNamed('hot_babe')
  end
  
  it "should find images with extension in app/assets" do
    OSX::NSImage.any_instance.expects(:initWithContentsOfFile).with(@image2)
    OSX::NSImage.imageNamed('not_so_hot_babe.png')
  end
  
  it "should pass any unfound image name on to the original implementation" do
    OSX::NSImage.expects(:super_imageNamed).with('whateva')
    OSX::NSImage.imageNamed('whateva')
  end
end