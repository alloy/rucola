require File.dirname(__FILE__) + '/test_helper.rb'
require 'pathname'
include Rucola

describe 'Rucola::RCApp' do
  before do
    @root_path = '/some/path/to/root'
    ::RUBYCOCOA_ROOT = Pathname.new(@root_path)
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
  
  it "should be included by default in the RCController class" do
    RCController.include?(RCApp).should.be true
    RCController.alloc.init.send(:root_path).should == @root_path
    
    RCWindowController.include?(RCApp).should.not.be true
  end
end
