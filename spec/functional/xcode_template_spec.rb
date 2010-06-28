require File.expand_path("../../spec_helper", __FILE__)
require 'rucola/xcode/template'

describe "Rucola::XCode::Template" do
  it "renders a XCode pbxproj template" do
    template_file = fixture('MacRuby Application/MacRubyApp.xcodeproj/project.pbxproj')
    expected = read_fixture('expected/Übercøøl/Übercøøl.xcodeproj/project.pbxproj')
    template = Rucola::XCode::Template.new(XCodeTemplateContext.new, template_file)
    template.render.should == expected
  end
  
  it "renders a XCode Info.plist template" do
    template_file = fixture('MacRuby Application/Info.plist')
    expected = read_fixture('expected/Übercøøl/Info.plist')
    template = Rucola::XCode::Template.new(XCodeTemplateContext.new, template_file)
    template.render.should == expected
  end
  
  it "renders a XCode main.m template" do
    Date.stubs(:today).returns(Date.new(2010, 6, 26))
    
    template_file = fixture('MacRuby Application/main.m')
    expected = read_fixture('expected/Übercøøl/main.m')
    expected.force_encoding('ISO-8859-1')
    
    output = Rucola::XCode::Template.new(XCodeTemplateContext.new, template_file).render
    output.force_encoding('ISO-8859-1')
    
    output.encode('UTF-8').should == expected.encode('UTF-8')
  end
  
  it "renders a XCode rb_main.rb template" do
    Date.stubs(:today).returns(Date.new(2010, 6, 26))
    
    template_file = fixture('MacRuby Application/rb_main.rb')
    expected = read_fixture('expected/Übercøøl/rb_main.rb')
    expected.force_encoding('ISO-8859-1')
    
    output = Rucola::XCode::Template.new(XCodeTemplateContext.new, template_file).render
    output.force_encoding('ISO-8859-1')
    
    output.encode('UTF-8').should == expected.encode('UTF-8')
  end
end
