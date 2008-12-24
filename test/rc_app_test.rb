#!/usr/local/bin/macruby

require File.expand_path('../test_helper', __FILE__)

class FooController; end
class Person; end
class PreferencesController; end

describe 'Rucola::RCApp' do
  before do
    @root_path = ::RUCOLA_ROOT
  end
  
  it "should return the name of the application" do
    plist = Rucola::InfoPlist.new(nil)
    plist.instance_variable_set(:@data, {'CFBundleExecutable' => 'PhatApp'})
    Rucola::InfoPlist.expects(:open).with((@root_path + 'config/Info.plist').to_s).returns(plist)
    Rucola::RCApp.app_name.should == 'PhatApp'
  end
  
  it "should return the path to the current root dir" do
    Rucola::RCApp.root_path.should == ::RUCOLA_ROOT
  end
  
  it "should return the path to the current controllers dir" do
    Rucola::RCApp.controllers_path.should == "#{@root_path}/app/controllers"
  end
  
  it "should return the path to the current models dir" do
    Rucola::RCApp.models_path.should == "#{@root_path}/app/models"
  end
  
  it "should return the path to the current views dir" do
    Rucola::RCApp.views_path.should == "#{@root_path}/app/views"
  end
  
  it "should return the path to the current assets dir" do
    Rucola::RCApp.assets_path.should == "#{@root_path}/app/assets"
  end
  
  it "should return the path for a given controller" do
    Rucola::RCApp.path_for_controller(FooController).should == "#{@root_path}/app/controllers/foo_controller.rb"
  end
  
  it "should return the path for a given model" do
    Rucola::RCApp.path_for_model(Person).should == "#{@root_path}/app/models/person.rb"
  end
  
  it "should return the path to this applications app support dir" do
    Rucola::RCApp.stubs(:app_name).returns('FooApp')
    Rucola::RCApp.application_support_path.should == File.expand_path('~/Library/Application Support/FooApp')
  end
  
  it "should return the path for a given view" do
    view_path = "#{@root_path}/app/views/Preferences.nib"
    Rucola::RCApp.path_for_view('Preferences').should == view_path
    Rucola::RCApp.path_for_view('preferences').should == view_path
    Rucola::RCApp.path_for_view(PreferencesController).should == view_path
    Rucola::RCApp.path_for_view(PreferencesController.new).should == view_path
  end
  
  it "should return the path for a given asset" do
    asset_path = "#{@root_path}/app/assets/somefile.png"
    Rucola::RCApp.path_for_asset('somefile.png').should == asset_path
    Rucola::RCApp.path_for_view('SomeFile.png').should.not == asset_path
  end
  
  xit "should be included by default in the RCController class" do
    Rucola::RCController.include?(Rucola::RCApp).should.be true
    Rucola::RCController.alloc.init.send(:root_path).should == @root_path
    
    Rucola::RCWindowController.include?(Rucola::RCApp).should.not.be true
  end
end