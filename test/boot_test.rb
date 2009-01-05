#!/usr/local/bin/macruby

require File.expand_path('../test_helper', __FILE__)

ENV['DONT_START_RUCOLA_APP'] = 'true'
BOOT_FILE = File.expand_path('../../new_templates/boot.rb', __FILE__)
require BOOT_FILE

describe "Rucola, when setting the environment" do
  after do
    silence_warnings { ::RUCOLA_ENV = 'test' }
    ENV.delete('RUCOLA_ENV')
    ENV.delete('DYLD_LIBRARY_PATH')
  end
  
  it "should use ENV['RUCOLA_ENV'] if available" do
    ENV['RUCOLA_ENV'] = 'debug'
    Rucola.send(:discover_environment).should == 'debug'
  end
  
  it "should use the path returned by ENV['DYLD_LIBRARY_PATH'] which is set by xcode" do
    [
      ['/root/build/Release', 'release'],
      ['/root/to/build/Debug',   'debug'],
      ['/root/to/build/Test',    'test']
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

describe "Rucola, when setting the application root" do
  ORIGINAL_RUCOLA_ROOT = RUCOLA_ROOT
  
  after do
    silence_warnings do
      ::RUCOLA_ENV = 'test'
      ::RUCOLA_ROOT = ORIGINAL_RUCOLA_ROOT
    end
    ENV.delete('RUCOLA_ROOT')
  end
  
  it "should return ENV['RUCOLA_ROOT'] if available" do
    root = '/path/to/application/root'
    ENV['RUCOLA_ROOT'] = root
    Rucola.send(:discover_root).should == root
  end
  
  it "should return the path to the resources of the application bundle in `release'" do
    silence_warnings { ::RUCOLA_ENV = 'release' }
    Rucola.send(:discover_root).should ==
      NSBundle.mainBundle.resourcePath.fileSystemRepresentation
  end
  
  it "should return the root path relative to the boot.rb file in `test'" do
    Rucola.send(:discover_root).should == File.expand_path('../../', BOOT_FILE)
  end
  
  it "should return the root relative to ENV['DYLD_LIBRARY_PATH'] in other environments" do
    silence_warnings { ::RUCOLA_ENV = 'debug' }
    ENV['DYLD_LIBRARY_PATH'] = '/root/build/Debug'
    Rucola.send(:discover_root).should == '/root'
  end
  
  it "should set the RUCOLA_ROOT constant to what Rucola.discover_root returns, unless already defined" do
    Rucola.stubs(:discover_root).returns('/root')
    
    Rucola.set_root!
    RUCOLA_ROOT.should == ORIGINAL_RUCOLA_ROOT
    
    Object.send(:remove_const, :RUCOLA_ROOT)
    Rucola.set_root!
    RUCOLA_ROOT.should == Pathname.new('/root')
  end
end

describe "Rucola, the boot process" do
  xit "should pick the correct boot type" do
    
  end
  
  it "should start the configuration processing" do
    boot = Rucola::Boot.new
    boot.stubs(:load_initializer)
    Rucola::Initializer.expects(:process)
    boot.run
  end
end