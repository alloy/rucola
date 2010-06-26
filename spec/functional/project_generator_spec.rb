require File.expand_path("../../spec_helper", __FILE__)
require 'rucola/generators/rucola/project/project_generator'

require 'fileutils'
require 'tempfile'

describe "A project generator" do
  extend Rucola::Generators::Project
  extend FileUtils
  
  name = 'Übercøøl'
  dir  = Dir.tmpdir
  destination = File.join(dir, name)
  
  ARGV[0] = destination
  AppGenerator.start
  
  it "creates the project root" do
    File.should.exist destination
  end
  
  it "generates the xcodeproj" do
    pbxproj = File.join(destination, "#{name}.xcodeproj/project.pbxproj")
    File.should.exist pbxproj
    File.read(pbxproj).should == read_fixture('expected/Übercøøl/Übercøøl.xcodeproj/project.pbxproj')
  end
  
  rm_rf destination
end