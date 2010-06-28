# encoding: UTF-8
require File.expand_path("../../../spec_helper", __FILE__)
require 'rucola/xcode/project'

describe "Rucola::XCode::Project" do
  before do
    @path = fixture('expected/Übercøøl/Übercøøl.xcodeproj')
    @project = Rucola::XCode::Project.new(@path)
  end
  
  def data
    @data ||= Hash.dictionaryWithContentsOfFile(File.join(@path, 'project.pbxproj'))
  end
  
  it "loads and returns the data at the given project path" do
    @project.data.should == data
  end
  
  it "returns the `objects'" do
    @project.objects.should == data['objects']
  end
  
  it "returns just the file objects" do
    @project.file_objects.should.not.be.empty
    @project.file_objects.each do |uuid, object|
      object['isa'].should == 'PBXFileReference'
    end
  end
  
  it "returns a file object by filename" do
    uuid, object = @project.file_object('run_suite.rb')
    uuid.should == '17D55CD81076A1A2008207BD'
    object['path'].should == 'run_suite.rb'
  end
  
  it "returns just the group objects" do
    @project.group_objects.should.not.be.empty
    @project.group_objects.each do |uuid, object|
      object['isa'].should == 'PBXGroup'
    end
  end
  
  it "returns groups by a matching child object" do
    child_uuid = '17D55CD81076A1A2008207BD'
    groups = @project.group_objects_by_child_uuid(child_uuid)
    groups.length.should == 1
    uuid, object = groups.first
    uuid.should == '172754AE1075979200D0347B'
    object['children'].should.include child_uuid
  end
  
  it "returns a group object by group name" do
    uuid, object = @project.group_object('Tests')
    uuid.should == '172754AE1075979200D0347B'
    object['path'].should == 'Tests'
  end
  
  it "removes a file object by filename and from the groups it belongs to" do
    @project.remove_file('run_suite.rb')
    @project.file_object('run_suite.rb').should == nil
    @project.group_objects_by_child_uuid('17D55CD81076A1A2008207BD').should.be.empty
  end
  
  it "removes a group by a group name" do
    @project.remove_group('Tests')
    @project.group_objects_by_child_uuid('17D55CD81076A1A2008207BD').should.be.empty
  end
end