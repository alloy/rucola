# encoding: UTF-8
require File.expand_path("../../../spec_helper", __FILE__)
require 'rucola/xcode/template'

describe "Rucola::XCode::Template" do
  before do
    @template = Rucola::XCode::Template.new(nil, nil)
  end
  
  it "returns the full user name" do
    @template.FULLUSERNAME.should == NSFullUserName()
  end
  
  it "returns the date" do
    @template.DATE.should == Date.today.strftime("%d-%m-%y")
  end
  
  it "returns the year with century" do
    @template.YEAR.should == Date.today.year
  end
  
  it "returns a stub organization name" do
    @template.ORGANIZATIONNAME.should == '__MyCompanyName__'
  end
end
