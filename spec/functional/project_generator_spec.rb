require File.expand_path("../../spec_helper", __FILE__)
require 'rucola/generators/rucola/project/project_generator'

require 'tempfile'

describe "A project generator" do
  extend Rucola::Generators::Project
  
  Date.stubs(:today).returns(Date.new(2010, 6, 26))
  
  run_generator(AppGenerator, 'Übercøøl', fixture('MacRuby Application')) do
    it "creates the project root" do
      dir @destination
    end
    
    it "generates the root files" do
      file "Info.plist", "UTF-8"
      file "main.m",     "ISO-8859-1"
      file "rb_main.rb", "ISO-8859-1"
    end
    
    it "generates the xcodeproj bundle" do
      file "Übercøøl.xcodeproj/project.pbxproj", "UTF-8"
    end
    
    it "generates the English.lproj bundle" do
      file "English.lproj/MainMenu.xib", "UTF-8"
      file "English.lproj/InfoPlist.strings", "UTF-16BE"
    end
  end
end