#!/usr/local/bin/macruby

require File.expand_path('../test_helper', __FILE__)

describe "Rucola::Initializer" do
  it "should initialize and cache a Configuration instance" do
    Rucola::Initializer.instance_variable_set(:@configuration, nil)
    config = Rucola::Initializer.configuration
    
    config.should.be.instance_of Rucola::Configuration
    Rucola::Initializer.configuration.should.be config
  end
  
  it "should yield the configuration instance when using Initializer.run" do
    config = nil
    Rucola::Initializer.run { |c| config = c }
    
    config.should.be Rucola::Initializer.configuration
  end
  
  %w{ test debug release }.each do |env|
    it "should load the global environment.rb file and config/environments/#{env}.rb" do
      with_env(env) do
        Rucola::Initializer.expects(:require).with(Rucola::RCApp.root_path + 'config/environment.rb')
        Rucola::Initializer.expects(:require).with(Rucola::RCApp.root_path + "config/environments/#{env}.rb")
        
        Rucola::Initializer.load_environment
      end
    end
  end
end

describe "Rucola::Configuration" do
  before do
    @config = Rucola::Configuration.new
  end
  
  it "should have a frameworks accessor with ['Cocoa'] as it's default" do
    @config.frameworks << 'WebKit'
    @config.frameworks << 'AddressBook'
    @config.frameworks.should == %w{ Cocoa WebKit AddressBook }
  end
end