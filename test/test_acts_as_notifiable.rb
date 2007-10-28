require File.dirname(__FILE__) + '/test_helper.rb'
require 'rucola/rucola_support/acts_as/notifiable'

class FooNotifiable < OSX::NSObject
  include Rucola::ActsAs::Notifiable
end
class BarNotifiable < OSX::NSObject
  include Rucola::ActsAs::Notifiable
end
class BazNotifiable < OSX::NSObject
  include Rucola::ActsAs::Notifiable
end
class BlaNotifiable < OSX::NSObject
  include Rucola::ActsAs::Notifiable
end
class FuNotifiable < OSX::NSObject
  include Rucola::ActsAs::Notifiable
end
class KungNotifiable < OSX::NSObject
  include Rucola::ActsAs::Notifiable
end
class Person < OSX::NSObject
  include Rucola::ActsAs::Notifiable
end

describe 'ActsAs::Notifiable' do
  it "should handle notifications when included" do
    FooNotifiable.instance_variable_get(:@_registered_notifications).should.be.nil
    
    FooNotifiable.notify_on 'FooNotification' do |notification|
      some_instance_method
    end
    
    FooNotifiable.instance_variable_get(:@_registered_notifications).length.should.be 1
    
    instance = FooNotifiable.alloc.init
    instance.methods.should.include '_handle_foo_notification'
    
    instance.expects(:some_instance_method)
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object('FooNotification', self)
  end
  
  it "should be able to handle the original string representations of the notifications" do
    BarNotifiable.notify_on 'NSApplicationDidFinishLaunchingNotification' do |notification|
      app_finished_launching
    end
    
    BarNotifiable.alloc.init.expects(:app_finished_launching)
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object(OSX::NSApplicationDidFinishLaunchingNotification, self)
  end
  
  it "should also be able to handle the abbreviated symbol representation of a notification" do
    BazNotifiable.notify_on :application_did_become_active do |notification|
      app_did_become_active
    end
    
    BazNotifiable.alloc.init.expects(:app_did_become_active)
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object(OSX::NSApplicationDidBecomeActiveNotification, self)
  end
  
  it "should raise a NameError exception if the abbreviated notification wasn't found" do
    lambda { BlaNotifiable.notify_on :does_not_exist do |notification|; end }.should.raise NameError
  end
  
  it "should also allow the user to define shortcuts" do
    FuNotifiable.notification_prefix :win => :window
    
    FuNotifiable.notify_on :win_did_become_key do |notification|
      window_did_become_key
    end
  
    FuNotifiable.alloc.init.expects(:window_did_become_key)
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object(OSX::NSWindowDidBecomeKeyNotification, self)
  end
  
  it "should by default have the shortcut app => application" do
    KungNotifiable.notify_on :app_will_terminate do |notification|
      app_will_terminate_called!
    end
    
    KungNotifiable.alloc.init.expects(:app_will_terminate_called!)
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object(OSX::NSApplicationWillTerminateNotification, self)
  end
  
  it "should call a given method when a certain notification is called" do
    Person.notify :method_to_notify, :when => 'MyNotification'
    Person.alloc.init.expects(:method_to_notify)
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object("MyNotification", nil)
  end
end
