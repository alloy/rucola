require File.expand_path("../../spec_helper", __FILE__)
require 'rucola/generators/xcode_template'

class XCodeTemplateContext
  def PROJECTNAME
    'Übercøøl'
  end
  alias :PROJECTNAMEASXML :PROJECTNAME
end

describe "XCodeTemplate" do
  before do
    @template = XCodeTemplate.new(nil, nil)
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
    @template.ORGANIZATIONNAME.should == '__MyCompany__'
  end
end
