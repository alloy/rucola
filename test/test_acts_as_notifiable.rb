require "rubygems"
require "test/unit"
require "test/spec"
require "mocha"
require 'osx/cocoa'

require "rucola/rucola_support/acts_as/notifiable"

class FooNotifiable < OSX::NSObject; end

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
end
