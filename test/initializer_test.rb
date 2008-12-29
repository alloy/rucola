#!/usr/local/bin/macruby

require File.expand_path('../test_helper', __FILE__)

describe "Rucola::Initializer" do
  it "should initialize and cache a Rucola::Configuration instance" do
    Rucola::Initializer.instance_variable_set(:@configuration, nil)
    config = Rucola::Initializer.configuration
    config.should.be.instance_of Rucola::Configuration
    Rucola::Initializer.configuration.should.be config
  end
  
  it "should yield the configuration instance when using Rucola::Initializer.run" do
    config = nil
    Rucola::Initializer.run { |c| config = c }
    config.should.be Rucola::Initializer.configuration
  end
end