require File.expand_path('../test_helper', __FILE__)
require 'rucola/plugin'

include Rucola

class FooPlugin < Rucola::Plugin
end

describe 'Plugin' do
  before do
    @plugin = Rucola::Plugin.plugins.first
    @initializer_mock = mock('Initializer')
  end
  
  it "contains list of plugin subclasses" do
    Rucola::Plugin.plugins.map { |p| p.class }.should == [FooPlugin]
  end
  
  it "should run before boot plugins" do
    @plugin.expects(:before_boot)
    Rucola::Plugin.before_boot
  end
  
  it "should run after boot plugins" do
    @plugin.expects(:after_boot)
    Rucola::Plugin.after_boot
  end
  
  it "should run before process plugins" do
    @plugin.expects(:before_process).with(@initializer_mock)
    Rucola::Plugin.before_process(@initializer_mock)
  end
  
  it "should run after process plugins" do
    @plugin.expects(:after_process).with(@initializer_mock)
    Rucola::Plugin.after_process(@initializer_mock)
  end
  
  it "should be able to run after launch plugins" do
    @plugin.expects(:after_launch)
    Rucola::Plugin.after_launch
  end
  
  it "should run after launch plugins when the app has started" do
    @plugin.expects(:after_launch)
    OSX::NSNotificationCenter.defaultCenter.postNotificationName_object(OSX::NSApplicationDidFinishLaunchingNotification, self)
  end
end