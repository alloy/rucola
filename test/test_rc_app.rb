require File.dirname(__FILE__) + '/test_helper.rb'
require 'pathname'
include Rucola

class FooController; end
class Person; end
class PreferencesController; end

describe 'Rucola::RCApp' do
  before do
    @root_path = '/some/path/to/root'
    ::RUBYCOCOA_ROOT = Pathname.new(@root_path)
  end
  
  it "should return the name of the application" do
    OSX::NSDictionary.expects(:dictionaryWithContentsOfFile).returns({'CFBundleExecutable' => 'PhatApp'})
    RCApp.app_name.should == 'PhatApp'
  end
  
  it "should return the path to the current root dir" do
    RCApp.root_path.should == @root_path
  end
  
  it "should return the path to the current controllers dir" do
    RCApp.controllers_path.should == "#{@root_path}/app/controllers"
  end
  
  it "should return the path to the current models dir" do
    RCApp.models_path.should == "#{@root_path}/app/models"
  end
  
  it "should return the path to the current views dir" do
    RCApp.views_path.should == "#{@root_path}/app/views"
  end
  
  it "should return the path to the current assets dir" do
    RCApp.assets_path.should == "#{@root_path}/app/assets"
  end
  
  it "should return the path for a given controller" do
    RCApp.path_for_controller(FooController).should == "#{@root_path}/app/controllers/foo_controller.rb"
  end
  
  it "should return the path for a given model" do
    RCApp.path_for_model(Person).should == "#{@root_path}/app/models/person.rb"
  end
  
  it "should return the path to this applications app support dir" do
    RCApp.stubs(:app_name).returns('FooApp')
    RCApp.application_support_path.should == File.expand_path('~/Library/Application Support/FooApp')
  end
  
  it "should return the path for a given view" do
    view_path = "#{@root_path}/app/views/Preferences.nib"
    RCApp.path_for_view('Preferences').should == view_path
    RCApp.path_for_view('preferences').should == view_path
    RCApp.path_for_view(PreferencesController).should == view_path
    RCApp.path_for_view(PreferencesController.new).should == view_path
  end
  
  it "should return the path for a given asset" do
    asset_path = "#{@root_path}/app/assets/somefile.png"
    RCApp.path_for_asset('somefile.png').should == asset_path
    RCApp.path_for_view('SomeFile.png').should.not == asset_path
  end
  
  it "should be included by default in the RCController class" do
    RCController.include?(RCApp).should.be true
    RCController.alloc.init.send(:root_path).should == @root_path
    
    RCWindowController.include?(RCApp).should.not.be true
  end
end