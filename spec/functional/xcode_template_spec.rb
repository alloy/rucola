require File.expand_path("../../spec_helper", __FILE__)
require 'rucola/generators/xcode_template'

describe "XCodeTemplate" do
  it "renders a XCode pbxproj template" do
    template_file = fixture('MacRuby Application/MacRubyApp.xcodeproj/project.pbxproj')
    expected = read_fixture('expected/Übercøøl/Übercøøl.xcodeproj/project.pbxproj')
    template = XCodeTemplate.new(XCodeTemplateContext.new, template_file)
    template.render.should == expected
  end
  
  it "renders a XCode Info.plist template" do
    template_file = fixture('MacRuby Application/Info.plist')
    expected = read_fixture('expected/Übercøøl/Info.plist')
    template = XCodeTemplate.new(XCodeTemplateContext.new, template_file)
    template.render.should == expected
  end
  
  it "renders a XCode main.m template" do
    Date.stubs(:today).returns(Date.new(2010, 6, 26))
    
    template_file = fixture('MacRuby Application/main.m')
    expected = read_fixture('expected/Übercøøl/main.m')
    template = XCodeTemplate.new(XCodeTemplateContext.new, template_file)
    template.render.should == expected
  end
  
  it "renders a XCode rb_main.rb template" do
    Date.stubs(:today).returns(Date.new(2010, 6, 26))
    
    template_file = fixture('MacRuby Application/rb_main.rb')
    expected = read_fixture('expected/Übercøøl/rb_main.rb')
    template = XCodeTemplate.new(XCodeTemplateContext.new, template_file)
    template.render.should == expected
  end
end
