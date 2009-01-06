#!/usr/bin/env macruby

require File.expand_path('../test_helper', __FILE__)
require "rucola/initializer"
require "rucola/support/rc_app"

describe "Rucola::Initializer" do
  include Rucola
  
  it "should initialize and cache a Configuration instance" do
    Initializer.instance_variable_set(:@configuration, nil)
    config = Initializer.configuration
    
    config.should.be.instance_of Configuration
    Initializer.configuration.should.be config
  end
  
  it "should yield the configuration instance when using Initializer.run" do
    config = nil
    Initializer.run { |c| config = c }
    
    config.should.be Initializer.configuration
  end
  
  %w{ test debug release }.each do |env|
    it "should load the global environment.rb file and config/environments/#{env}.rb" do
      with_env(env) do
        Initializer.expects(:require).with(RCApp.root_path + 'config/environment.rb')
        Initializer.expects(:require).with(RCApp.root_path + "config/environments/#{env}.rb")
        
        Initializer.load_environment
      end
    end
  end
  
  it "should set the load path, which should be Configuration#load_paths reversed, without duplicates" do
    before = $LOAD_PATH.dup
    
    config = Initializer.configuration
    config.load_paths << '/some/load/path'
    config.load_paths << '/some/load/path'
    
    config.load_paths.each { |f| $LOAD_PATH.should.not.include f }
    
    Initializer.set_load_path
    
    $LOAD_PATH[0...config.load_paths.length - 1].reverse.should == config.load_paths[0..-2].reverse
    $LOAD_PATH.uniq!.should.be nil
    
    $LOAD_PATH.replace(before)
  end
  
  it "should load the required frameworks" do
    Initializer.configuration.frameworks << 'WebKit'
    Initializer.expects(:framework).with('Cocoa')
    Initializer.expects(:framework).with('WebKit')
    Initializer.load_frameworks
  end
  
  it "should load the application classes" do
    RCApp.stubs(:root_path).returns(Pathname.new(FIXTURES))
    %w{
      app/controllers/application_controller.rb
      app/controllers/other_controller.rb
      app/models/model.rb
      app/views/view.rb
    }.map { |dir| (RCApp.root_path + dir).to_s }.each do |file|
      Initializer.expects(:require).with(file)
    end
    
    Initializer.load_application_files
  end
  
  it "should load plugins" do
    RCApp.stubs(:root_path).returns(Pathname.new(FIXTURES))
    %w{ plugin/init.rb another_plugin/init.rb }.each do |file|
      Initializer.expects(:require).with(RCApp.plugins_path + file)
    end
    Initializer.load_plugins
  end
  
  it "should start the configuration processing and call all initialization methods" do
    Initializer.expects(:load_environment)
    Initializer.expects(:load_plugins)
    Initializer.expects(:set_load_path)
    Initializer.expects(:load_frameworks)
    Initializer.expects(:load_application_files)
    
    Initializer.process
  end
end

describe "Rucola::Configuration" do
  before do
    @config = Rucola::Configuration.new
  end
  
  it "should have a frameworks accessor" do
    @config.frameworks << 'WebKit'
    @config.frameworks.should == %w{ Cocoa WebKit }
  end
  
  it "should have a load_paths accessor" do
    @config.load_paths << '/some/load/path'
    
    paths = %w{
      app/controllers
      app/models
      app/views
      lib
      vendor
    }.map { |dir| (RCApp.root_path + dir).to_s }
    paths << '/some/load/path'
    
    @config.load_paths.should == paths
  end
end