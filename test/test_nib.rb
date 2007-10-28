require File.expand_path('../test_helper', __FILE__)

require File.expand_path('../../lib/rucola/nib', __FILE__)
include Rucola

require 'pp'

describe 'Nib::Classes' do
  before do
    @path = FIXTURES + '/MainMenu.nib/classes.nib'
    @nib = Nib::Classes.open(@path)
  end
  
  it "should be able to load the classes.nib" do
    @nib.data.should.be.an.instance_of OSX::NSCFDictionary
    @nib.classes.should.be.an.instance_of OSX::NSCFArray
    @nib.classes.first['CLASS'].should == 'ApplicationController'
  end
  
  it "should be able to add a subclass of NSObject" do
    before = @nib.classes.length
    @nib.add_class('FooController')
    @nib.classes.length.should.be before + 1
    
    @nib.classes.last.to_ruby.should == { 'CLASS' => 'FooController', "LANGUAGE"=>"ObjC", "SUPERCLASS"=>"NSObject" }
  end
  
  it "should be able to save the classes.nib" do
    backup = "/tmp/MainMenu.nib.bak"
    File.expects(:exists?).with(backup).returns(true)
    Kernel.expects(:system).with("rm -rf #{backup}")
    Kernel.expects(:system).with("cp -R #{File.dirname(@path)} #{backup}")
    
    @nib.data.expects(:writeToFile_atomically).with(@path, true)
    @nib.save
  end
end
