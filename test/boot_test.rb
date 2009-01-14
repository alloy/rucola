#!/usr/bin/env macruby

require File.expand_path('../test_helper', __FILE__)

BOOT_FILE = File.expand_path('../../new_templates/boot.rb', __FILE__)
require BOOT_FILE

module RakeHelper
  def with_rake
    with_env_var('WITH_RAKE') { yield }
  end
end

describe "Rucola, when setting the environment" do
  include RakeHelper
  
  it "should use ENV['RUCOLA_ENV'] if available" do
    with_env_var('RUCOLA_ENV', 'debug') do
      Rucola.send(:discover_environment).should == 'debug'
    end
  end
  
  it "should use the path returned by ENV['DYLD_LIBRARY_PATH'] which is set by xcode" do
    [
      ['/root/build/Release', 'release'],
      ['/root/to/build/Debug',   'debug'],
      ['/root/to/build/Test',    'test']
    ].each do |path, env|
      with_env_var('DYLD_LIBRARY_PATH', path) do
        Rucola.send(:discover_environment).should == env
      end
    end
  end
  
  it "should return `debug' if ENV['DYLD_LIBRARY_PATH'] returns a path to a directory not named `Release', `Debug' or `Test'" do
    with_env_var('DYLD_LIBRARY_PATH', '/path/to/build/Foo') do
      Rucola.send(:discover_environment).should == 'debug'
    end
  end
  
  it "should return `debug` if  running from rake" do
    with_rake do
      Rucola.send(:discover_environment).should == 'debug'
    end
  end
  
  it "should return `release' if non of the other predicates match" do
    Rucola.send(:discover_environment).should == 'release'
  end
  
  it "should set the RUCOLA_ENV constant to what Rucola.discover_environment returns, unless already defined" do
    with_env 'test' do
      Rucola.stubs(:discover_environment).returns('Foo')
      
      Rucola.set_environment!
      RUCOLA_ENV.should == 'test'
      
      Object.send(:remove_const, :RUCOLA_ENV)
      Rucola.set_environment!
      RUCOLA_ENV.should == 'Foo'
    end
  end
end

describe "Rucola, when setting the application root" do
  include RakeHelper
  
  it "should return ENV['RUCOLA_ROOT'] if available" do
    root = '/path/to/application/root'
    with_env_var('RUCOLA_ROOT', root) do
      Rucola.send(:discover_root).should == root
    end
  end
  
  it "should return the path to the resources of the application bundle in `release'" do
    with_env 'release' do
      Rucola.send(:discover_root).should ==
        NSBundle.mainBundle.resourcePath.fileSystemRepresentation
    end
  end
  
  it "should return the root path relative to the boot.rb file in `test'" do
    Rucola.send(:discover_root).should == File.expand_path('../../', BOOT_FILE)
  end
  
  it "should return the root path relative to the boot.rb file in `debug` if the `Rake` constant is defined, which would mean running from rake" do
    with_rake do
      with_env 'debug' do
        Rucola.send(:discover_root).should == File.expand_path('../../', BOOT_FILE)
      end
    end
  end
  
  it "should return the root relative to ENV['DYLD_LIBRARY_PATH'] in other environments" do
    with_env 'debug' do
      with_env_var('DYLD_LIBRARY_PATH', '/root/build/Debug') do
        Rucola.send(:discover_root).should == '/root'
      end
    end
  end
  
  it "should set the RUCOLA_ROOT constant to what Rucola.discover_root returns, unless already defined" do
    before = ::RUCOLA_ROOT
    
    with_root(before) do
      Rucola.stubs(:discover_root).returns('/root')
      
      Rucola.set_root!
      RUCOLA_ROOT.should == before
      
      Object.send(:remove_const, :RUCOLA_ROOT)
      Rucola.set_root!
      RUCOLA_ROOT.should == Pathname.new('/root')
    end
  end
end

describe "Rucola, the boot process" do
  it "should use Rucola::Boot::Vendor if 'root/vendor/rucola' exists" do
    with_root(Pathname.new(FIXTURES)) do
      Rucola.pick_boot.should.be.instance_of Rucola::Boot::Vendor
    end
  end
  
  it "should use Rucola::Boot::Gem if 'root/vendor/rucola' does not exists" do
    Rucola.pick_boot.should.be.instance_of Rucola::Boot::Gem
  end
  
  it "should start the configuration processing" do
    boot = Rucola::Boot.new
    boot.stubs(:load_initializer)
    Rucola::Initializer.expects(:process)
    boot.run
  end
end