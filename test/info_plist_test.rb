#!/usr/bin/env macruby

require File.expand_path('../test_helper', __FILE__)

describe "Info" do
  before do
    @path = FIXTURES + '/Info.plist'
    @info_plist = Rucola::InfoPlist.open(@path)
  end
  
  it "should be able to load an Info.plist file" do
    @info_plist.data.should.be.an.instance_of NSMutableDictionary
  end
  
  it "should be able to add document types" do
    before = @info_plist.document_types.length
    @info_plist.add_document_type('MyDocument', 'mydocextension', 'Editor')
    @info_plist.add_document_type('MyDocument2', 'mydocextension2', 'Editor')
    
    @info_plist.document_types.length.should.be before + 2
    
    @info_plist.document_types.should == [
      {"CFBundleTypeOSTypes"=>["????"], "CFBundleTypeExtensions"=>["mydocextension"], "NSDocumentClass"=>"MyDocument", "CFBundleTypeName"=>"DocumentType", "CFBundleTypeIconFile"=>"????", "CFBundleTypeRole"=>"Editor"},
      {"CFBundleTypeOSTypes"=>["????"], "CFBundleTypeExtensions"=>["mydocextension2"], "NSDocumentClass"=>"MyDocument2", "CFBundleTypeName"=>"DocumentType", "CFBundleTypeIconFile"=>"????", "CFBundleTypeRole"=>"Editor"}
    ]
  end
  
  it "should be able to save the plist" do
    @info_plist.data.expects('writeToFile:atomically:').with(@path, true)
    @info_plist.save
  end
  
  it "should be able to return the name of the application" do
    @info_plist.app_name.should == 'MyApp'
  end
end