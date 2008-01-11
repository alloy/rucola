require File.expand_path('../test_helper', __FILE__)
require 'rucola/reloader'

class SomeReloadableClass
  def self.a_original_class_method; end
  def a_original_instance_method; end
end

describe "Reloader" do
  it "should be able to reload a file/class" do
    SomeReloadableClass.instance_methods(false).should == ['a_original_instance_method']
    SomeReloadableClass.own_class_methods.should == ['a_original_class_method']
    
    Rucola::Reloader.reload("#{FIXTURES}/some_reloadable_class.rb")
    
    SomeReloadableClass.instance_methods(false).should == ['a_new_instance_method']
    SomeReloadableClass.own_class_methods.should == ['a_new_class_method']
  end
  
  it "should start watching app/controllers and reload a file if it has been modified" do
    file = '/some/path/some_controller.rb'
    event = mock('FSEvent')
    event.expects(:last_modified_file).returns(file)
    Rucola::FSEvents.expects(:start_watching).with(Rucola::RCApp.controllers_path).yields([event])
    Rucola::Reloader.expects(:reload).with(file)
    Rucola::Reloader.start!
  end
end