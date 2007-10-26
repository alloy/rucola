require "rubygems"
require "test/unit"
require "test/spec"
require "mocha"
require 'osx/cocoa'

require "rucola/rucola_support/acts_as/notifiable"

class FooNotifiable < OSX::NSObject; end
class BarNotifiable < OSX::NSObject; end
class BazNotifiable < OSX::NSObject; end
class BlaNotifiable < OSX::NSObject; end
class FuNotifiable < OSX::NSObject; end
class KungNotifiable < OSX::NSObject; end

describe 'ActsAs::Notifiable' do
  it "should register itself as an act" do
    FooNotifiable.methods.should.include 'acts_as_notifiable'
  end
  
  it "should handle notifications when included" do
    FooNotifiable.acts_as_notifiable
    
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
    BarNotifiable.acts_as_notifiable
    BarNotifiable.notify_on 'NSApplicationDidFinishLaunchingNotification' do |notification|
      app_finished_launching
    end
    
    instance = BarNotifiable.alloc.init
    instance.expects(:app_finished_launching)
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object(OSX::NSApplicationDidFinishLaunchingNotification, self)
  end
  
  it "should also be able to handle the abbreviated symbol representation of a notification" do
    BazNotifiable.acts_as_notifiable
    BazNotifiable.notify_on :application_did_become_active do |notification|
      app_did_become_active
    end
    
    instance = BazNotifiable.alloc.init
    instance.expects(:app_did_become_active)
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object(OSX::NSApplicationDidBecomeActiveNotification, self)
  end
  
  it "should raise a NameError exception if the abbreviated notification wasn't found" do
    BlaNotifiable.acts_as_notifiable
    lambda { BlaNotifiable.notify_on :does_not_exist do |notification|; end }.should.raise NameError
  end
  
  it "should also allow the user to define shortcuts" do
    FuNotifiable.acts_as_notifiable
    FuNotifiable.notification_prefix :win => :window
    
    FuNotifiable.notify_on :win_did_become_key do |notification|
      window_did_become_key
    end

    instance = FuNotifiable.alloc.init
    instance.expects(:window_did_become_key)
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object(OSX::NSWindowDidBecomeKeyNotification, self)
  end
  
  it "should by default have the shortcut app => application" do
    KungNotifiable.acts_as_notifiable
    
    KungNotifiable.notify_on :app_will_terminate do |notification|
      app_will_terminate_called!
    end
    
    instance = KungNotifiable.alloc.init
    instance.expects(:app_will_terminate_called!)
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object(OSX::NSApplicationWillTerminateNotification, self)
  end
end
