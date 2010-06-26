require File.expand_path("../../spec_helper", __FILE__)
require 'rucola/generators/xcode_template'

class XCodeTemplateContext
  def PROJECTNAME
    'Übercøøl'
  end
  alias :PROJECTNAMEASXML :PROJECTNAME
end

describe "XCodeTemplate" do
  it "renders a XCode pbxproj template" do
    template_file = fixture('MacRuby Application/MacRubyApp.xcodeproj/project.pbxproj')
    expected = read_fixture('expected/Übercøøl/Übercøøl.xcodeproj/project.pbxproj')
    template = XCodeTemplate.new(XCodeTemplateContext.new, template_file)
    template.render.should == expected
  end
  
  it "renders a XCode main.m template" do
    Date.stubs(:today).returns(Date.new(2010, 6, 25))
    
    template_file = fixture('MacRuby Application/main.m')
    expected = read_fixture('expected/Übercøøl/main.m')
    template = XCodeTemplate.new(XCodeTemplateContext.new, template_file)
    template.render.should == expected
  end
end
