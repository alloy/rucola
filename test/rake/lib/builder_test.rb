#!/usr/bin/env macruby

require File.expand_path('../../../test_helper', __FILE__)

describe "Rucola::Rake::Builder in `release'" do
  def setup
    @builder = Rucola::Rake::Builder.new('release')
  end
  
  it "should run the build without environment parameters" do
    Rucola::RCApp.stubs(:app_name).returns('MyApp')
    @builder.run
    should_have_executed :sh, [@builder.executable]
  end
  
  private
  
  include Rucola::Rake::TestHelper::Assertions
  
  def rake_lib_instance
    @builder
  end
end

%w{ debug test }.each do |env|
  describe "Rucola::Rake::Builder in `#{env}'" do
    # make the env variable available to the test instances
    define_method(:env) { env }
    
    def setup
      @root = Rucola::RCApp.root_path
      @builder = Rucola::Rake::Builder.new(env)
    end
    
    it "should return the `configuration'" do
      @builder.configuration.should == env.capitalize
    end
    
    it "should build the correct `configuration' if the environment is `#{env}'" do
      @builder.build
      should_have_executed :sh, ["xcodebuild -configuration #{@builder.configuration}"]
    end
    
    it "should return (Rucola::RCApp.root_path + build) when no custom build dir has been specified" do
      @builder.build_root.should == @root + 'build'
    end
    
    it "should return (Rucola::RCApp.root_path + build) when the user has XCode defaults but no custom build dir has been specified" do
      NSUserDefaults.standardUserDefaults.stubs(:[]).with('PBXApplicationwideBuildSettings').returns({})
      @builder.build_root.should == @root + 'build'
    end
    
    it "should return the path to the build root when the user has specified a build dir in XCode" do
      defaults = { 'SYMROOT' => '/global/build/dir' }
      NSUserDefaults.standardUserDefaults.stubs(:[]).with('PBXApplicationwideBuildSettings').returns(defaults)
      
      @builder.build_root.should == Pathname.new('/global/build/dir')
    end
    
    it "should return the path to the application bundle for the current `configuration'" do
      Rucola::RCApp.stubs(:app_name).returns('MyApp')
      @builder.application_bundle.should == @builder.build_root + env.capitalize + 'MyApp.app'
    end
    
    it "should return the path to the `executable'" do
      Rucola::RCApp.stubs(:app_name).returns('MyApp')
      @builder.executable.should == @builder.application_bundle + 'Contents/MacOS/MyApp'
    end
    
    it "should return the correct environment parameters" do
      @builder.environment_parameters.should == "RUCOLA_ENV='#{env}' RUCOLA_ROOT='#{Rucola::RCApp.root_path}'"
    end
    
    it "should run the build with the correct environment parameters if not in `release'" do
      Rucola::RCApp.stubs(:app_name).returns('MyApp')
      @builder.run
      should_have_executed :sh, ["#{@builder.environment_parameters} '#{@builder.executable}'"]
    end
    
    private
    
    include Rucola::Rake::TestHelper::Assertions
    
    def rake_lib_instance
      @builder
    end
  end
end