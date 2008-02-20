require File.expand_path('../test_helper', __FILE__)
require 'rucola/initializer'

RUBYCOCOA_ROOT = Pathname.new('/MyApp')

module Rucola::Reloader; end

describe "Initializer's Class methods" do
  # it "should load the plugins directly after loading the initializer file" do
  #   Rucola::Initializer.expects(:load_plugins)
  #   load 'rucola/initializer.rb'
  # end
  
  it "should return the path to the plugins root directory" do
    Rucola::Initializer.plugins_root.to_s.should == '/MyApp/vendor/plugins'
  end
  
  it "should load any plugins by requiring their init.rb files" do
    plugin_root_mock = mock('Plugin Root')
    Rucola::Initializer.expects(:plugins_root).returns(plugin_root_mock)
    plugin_root_mock.expects(:exist?).returns(true)
    
    dir_with_initrb_mock, dir_without_initrb_mock = mock('Dir'), mock('Dir without init.irb')
    plugin_root_mock.expects(:children).returns([dir_with_initrb_mock, dir_without_initrb_mock])
    
    initrb_for_dir_with_initrb_mock = mock('init.rb does exist')
    dir_with_initrb_mock.expects(:+).with('init.rb').returns(initrb_for_dir_with_initrb_mock)
    initrb_for_dir_with_initrb_mock.expects(:exist?).returns(true)
    Kernel.expects(:require).with(initrb_for_dir_with_initrb_mock)
    
    initrb_for_dir_without_initrb_mock = mock('init.rb does not exist')
    dir_without_initrb_mock.expects(:+).with('init.rb').returns(initrb_for_dir_without_initrb_mock)
    initrb_for_dir_without_initrb_mock.expects(:exist?).returns(false)
    
    Rucola::Initializer.load_plugins
  end
  
  it "should run any before and after boot plugins around the call to do_boot" do
    Rucola::Plugin.expects(:before_boot)
    Rucola::Initializer.expects(:do_boot)
    Rucola::Plugin.expects(:after_boot)
    Rucola::Initializer.boot
  end
  
  it "should perform the application's specific configuration and start the app" do
    config_mock = mock('Configuration')
    Rucola::Configuration.expects(:new).returns(config_mock)
    initializer_mock = mock('Initializer')
    Rucola::Initializer.expects(:new).with(config_mock).returns(initializer_mock)
    initializer_mock.expects(:process)
    Rucola::Initializer.expects(:start_app)
    
    Rucola::Initializer.run
  end
  
  it "should yield the configuration instance for setup purposes (this is used in the environments)" do
    config_mock = mock('Configuration')
    Rucola::Configuration.expects(:new).returns(config_mock)
    Rucola::Initializer.any_instance.expects(:process)
    Rucola::Initializer.expects(:start_app)
    
    Rucola::Initializer.run do |config|
      config.should.be config_mock
    end
  end
  
  it "should actually start the main app run loop" do
    OSX.expects(:NSApplicationMain)
    Rucola::Initializer.start_app
  end
  
  it "should not start the main app run loop if the RUBYCOCOA_ENV is 'test'" do
    ::RUBYCOCOA_ENV = 'test'
    OSX.expects(:NSApplicationMain).times(0)
    Rucola::Initializer.start_app
  end
  
  it "should not start the main app run loop if ENV['DONT_START_RUBYCOCOA_APP'] has been set" do
    ::RUBYCOCOA_ENV = 'release'
    ENV['DONT_START_RUBYCOCOA_APP'] = 'true'
    OSX.expects(:NSApplicationMain).times(0)
    Rucola::Initializer.start_app
  end
end

module StubConfigurationHelper
  def setup
    Rucola::Configuration.any_instance.stubs(:set_root_path!)
    Rucola::Configuration.any_instance.stubs(:set_application_support_path!)
    @config = Rucola::Configuration.new
  end
end

describe "Initializer's instance methods" do
  include StubConfigurationHelper
  
  it "should not start the Reloader if that's set in the config" do
    @config.use_reloader = false
    initializer = Rucola::Initializer.new(@config)
    
    Kernel.expects(:require).times(0)
    Rucola::Reloader.expects(:start!).times(0)
    initializer.require_reloader
  end
  
  it "should start the Reloader if that's set in the config" do
    @config.use_reloader = true
    initializer = Rucola::Initializer.new(@config)
    
    Kernel.expects(:require).with('rucola/reloader')
    Rucola::Reloader.expects(:start!)
    initializer.require_reloader
  end
end

describe "Configuration" do
  include StubConfigurationHelper
  
  it "should use the reloader by default if the RUBYCOCOA_ENV is set to 'debug'" do
    Rucola::Configuration.new.ivar(:use_reloader).should.be false
    old_env = RUBYCOCOA_ENV
    RUBYCOCOA_ENV = 'debug'
    Rucola::Configuration.new.ivar(:use_reloader).should.be true
    RUBYCOCOA_ENV = old_env
  end
end

# TODO: test dependencies.
