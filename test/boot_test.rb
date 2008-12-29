#!/usr/local/bin/macruby

require File.expand_path('../test_helper', __FILE__)

ENV['DONT_START_RUCOLA_APP'] = 'true'
require File.expand_path('../../new_templates/boot.rb', __FILE__)

describe "Rucola, when setting the environment" do
  after do
    RUCOLA_ENV = 'test'
    ENV.delete('RUCOLA_ENV')
    ENV.delete('DYLD_LIBRARY_PATH')
  end
  
  it "should use ENV['RUCOLA_ENV'] if available" do
    ENV['RUCOLA_ENV'] = 'debug'
    Rucola.send(:discover_environment).should == 'debug'
  end
  
  it "should use the path returned by ENV['DYLD_LIBRARY_PATH'] which is set by xcode" do
    [
      ['/path/to/build/Release', 'release'],
      ['/path/to/build/Debug',   'debug'],
      ['/path/to/build/Test',    'test']
    ].each do |path, env|
      ENV['DYLD_LIBRARY_PATH'] = path
      Rucola.send(:discover_environment).should == env
    end
  end
  
  it "should return `debug' if ENV['DYLD_LIBRARY_PATH'] returns a path to a directory not named `Release', `Debug' or `Test'" do
    ENV['DYLD_LIBRARY_PATH'] = '/path/to/build/Foo'
    Rucola.send(:discover_environment).should == 'debug'
  end
  
  it "should return `release' if non of the other predicates match" do
    Rucola.send(:discover_environment).should == 'release'
  end
  
  it "should set the RUCOLA_ENV constant to what Rucola.discover_environment returns, unless already defined" do
    Rucola.stubs(:discover_environment).returns('Foo')
    
    Rucola.set_environment!
    RUCOLA_ENV.should == 'test'
    
    Object.send(:remove_const, :RUCOLA_ENV)
    Rucola.set_environment!
    RUCOLA_ENV.should == 'Foo'
  end
end