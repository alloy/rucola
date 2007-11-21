require File.expand_path('../test_helper', __FILE__)
require 'rucola/initializer'

RUBYCOCOA_ROOT = Pathname.new('/MyApp')

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
    
    dir_mock, file_mock = mock('Dir'), mock('File')
    plugin_root_mock.expects(:children).returns([file_mock, dir_mock])
    
    file_mock.expects(:directory?).returns(false)
    dir_mock.expects(:directory?).returns(true)
    
    init_rb_path = '/MyApp/vendor/plugins/Foo/init.rb'
    dir_mock.expects(:+).with('init.rb').returns(init_rb_path)
    Kernel.expects(:require).with(init_rb_path)
    
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