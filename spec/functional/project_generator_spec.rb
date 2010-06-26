require File.expand_path("../../spec_helper", __FILE__)
require 'rucola/generators/rucola/project/project_generator'

require 'fileutils'
require 'tempfile'

describe "A project generator" do
  extend Rucola::Generators::Project
  extend FileUtils
  
  @destination = File.join(Dir.tmpdir, 'Übercøøl')
  
  def file(path)
    template = File.join('expected/Übercøøl', path)
    output   = File.join(@destination, path)
    
    File.should.exist output
    File.read(output).should == read_fixture(template)
  end
  
  def dir(path)
    File.should.exist path
    File.should.be.directory path
  end
  
  Date.stubs(:today).returns(Date.new(2010, 6, 25))
  ARGV[0] = @destination
  AppGenerator.start
  
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
  
  mocha_teardown
  rm_rf @destination
end