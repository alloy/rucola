require File.dirname(__FILE__) + '/test_helper.rb'

class FooNotifiable < Rucola::RCController; end
class Person < Rucola::RCController; end
class Shipping < Rucola::RCController
  notify :update_shipping, :when => :address_was_changed
  def update_shipping(notification); end
end

describe 'Rucola::Notifications' do
  after do
    OSX::NSNotificationCenter.defaultCenter.removeObserver(@instance)
  end
  
  it "should handle notifications when included" do
    FooNotifiable.instance_variable_get(:@_registered_notifications).should.be.nil
    
    FooNotifiable.when 'FooNotification' do |notification|
      some_instance_method
    end
    
    FooNotifiable.instance_variable_get(:@_registered_notifications).length.should.be 1
    
    instance = FooNotifiable.alloc.init
    instance.methods.should.include '_handle_foo_notification'
    
    instance.expects(:some_instance_method)
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object('FooNotification', self)
  end
  
  it "should be able to handle the original string representations of the notifications" do
    FooNotifiable.when 'NSApplicationDidFinishLaunchingNotification' do |notification|
      app_finished_launching
    end
    
    @instance = FooNotifiable.alloc.init
    @instance.expects(:app_finished_launching)
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object(OSX::NSApplicationDidFinishLaunchingNotification, self)
  end
  
  it "should also be able to handle the abbreviated symbol representation of a notification" do
    FooNotifiable.when :application_did_become_active do |notification|
      app_did_become_active
    end
    
    @instance = FooNotifiable.alloc.init
    @instance.expects(:app_did_become_active)
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object(OSX::NSApplicationDidBecomeActiveNotification, self)
  end
  
  it "should also allow the user to define shortcuts" do
    FooNotifiable.notification_prefix :win => :window
    
    FooNotifiable.when :win_did_become_key do |notification|
      window_did_become_key
    end
    
    @instance = FooNotifiable.alloc.init
    @instance.expects(:window_did_become_key)
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object(OSX::NSWindowDidBecomeKeyNotification, self)
  end
  
  it "should by default have the shortcut app => application" do
    FooNotifiable.when :app_will_terminate do |notification|
      app_will_terminate_called!
    end
    
    @instance = FooNotifiable.alloc.init
    @instance.expects(:app_will_terminate_called!)
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object(OSX::NSApplicationWillTerminateNotification, self)
  end
  
  it "should call a given method when a certain notification is called" do
    Person.notify :method_to_notify, :when => 'MyNotification'
    Person.alloc.init.expects(:method_to_notify)
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object("MyNotification", nil)
  end
  
  it "should fire notifications" do
    shipping = Shipping.alloc.init
    shipping.expects(:update_shipping)
    Shipping.fire_notification(:address_was_changed, nil)
  end
end
