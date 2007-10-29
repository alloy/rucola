require File.expand_path('../test_helper', __FILE__)

require File.expand_path('../../lib/rucola/nib', __FILE__)
include Rucola

describe 'Nib' do
  it "should be able to backup a nib" do
    path = '/some/path/MainMenu.nib/classes.nib'
    backup = "/tmp/MainMenu.nib.bak"
    File.expects(:exists?).with(backup).returns(true)
    FileUtils.expects(:rm_rf).with(backup)
    FileUtils.expects(:cp_r).with(File.dirname(path), backup)
    Rucola::Nib.backup(path)
  end
end

describe 'Nib::Classes' do
  before do
    @path = FIXTURES + '/MainMenu.nib/classes.nib'
    @nib = Nib::Classes.open(@path)
  end
  
  it "should be able to load the classes.nib" do
    @nib.data.should.be.an.instance_of OSX::NSCFDictionary
    @nib.classes.should.be.an.instance_of OSX::NSCFArray
    @nib.classes.last['CLASS'].should == 'ApplicationController'
  end
  
  it "should be able to add a subclass of NSObject" do
    before = @nib.classes.length
    @nib.add_class('FooController')
    @nib.classes.length.should.be before + 1
    
    @nib.classes.last.to_ruby.should == { 'CLASS' => 'FooController', "LANGUAGE"=>"ObjC", "SUPERCLASS"=>"NSObject" }
  end
  
  it "should be able to save the classes.nib" do
    Rucola::Nib.expects(:backup).with(@path)
    @nib.data.expects(:writeToFile_atomically).with(@path, true)
    @nib.save
  end
  
  it "should be able to check if a class is defined" do
    @nib.add_class('BarController')
    @nib.has_class?('BarController').should.be true
    @nib.has_class?('NotInThere').should.be false
  end
end

describe 'Nib::KeyedObjects' do
  before do
    @path = FIXTURES + '/MainMenu.nib/keyedobjects.nib'
    @nib = Nib::KeyedObjects.open(@path)
  end
  
  it "should be able to load the keyedobjects.nib" do
    @nib.data.should.be.an.instance_of OSX::NSCFDictionary
  end
  
  it "should be able to change the custom class of the File's owner" do
    @nib.change_files_owner_class('Japie')
    @nib.files_owner_class.should == 'Japie'
  end
  
  it "should be able to save the keyedobjects.nib" do
    plist_mock = mock('Serialized Plist mock')
    OSX::NSPropertyListSerialization.expects(:dataFromPropertyList_format_errorDescription).with(@nib.data, OSX::NSPropertyListBinaryFormat_v1_0).returns(plist_mock)
    Rucola::Nib.expects(:backup).with(@path)
    File.expects(:exists?).with(File.dirname(@path))
    plist_mock.expects(:writeToFile_atomically).with(@path, true)
    @nib.save
  end
end