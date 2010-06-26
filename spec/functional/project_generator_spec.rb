require File.expand_path("../../spec_helper", __FILE__)
require 'rucola/generators/rucola/project/project_generator'

require 'tempfile'

describe "A project generator" do
  extend Rucola::Generators::Project
  
  Date.stubs(:today).returns(Date.new(2010, 6, 25))
  
  run_generator(AppGenerator, 'Übercøøl') do
    it "creates the project root" do
      dir @destination
    end
    
    it "generates the xcodeproj" do
      file "Übercøøl.xcodeproj/project.pbxproj"
    end
    
    it "generates the root files" do
      file "Info.plist"
      file "rb_main.rb"
      file "main.m"
    end
  end
end