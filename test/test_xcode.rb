require "rubygems"
require "test/unit"
require "test/spec"
require 'mocha'

require File.expand_path('../../lib/rucola/xcode', __FILE__)
include Rucola

describe 'Xcode' do
  before do
    @name = 'Baz'
    @project_path = "/foo/bar/#{@name}.xcodeproj"
    @data_path = "#{@project_path}/project.pbxproj"
    
    @object_id = '519A79DB0CC8AE6B00CBE85E'.to_ns
    @object_values = { 'isa' => 'PBXNativeTarget', 'name' => @name, 'buildPhases' => [] }.to_ns
    @object = [@object_id, @object_values]
    @data = { 'objects' => { @object_id => @object_values } }.to_ns
    OSX::NSMutableDictionary.stubs(:dictionaryWithContentsOfFile).with(@data_path).returns(@data)
    
    @project = Xcode.new(@project_path)
    # Add a stub `Linked Frameworks` group
    @project.objects['1058C7A0FEA54F0111CA2CBB'] = { 'name' => 'Linked Frameworks', 'children' => [] }.to_ns
  end
  
  it "should initialize" do
    OSX::NSMutableDictionary.expects(:dictionaryWithContentsOfFile).with(@data_path).returns(@data)
    
    project = Xcode.new(@project_path)
    project.project_path.to_s.should == @project_path
    project.project.should == @name
    project.project_data.should == @data
  end
  
  it "should save the data back as a plist" do
    # atm we don't generate id's, so let's at least make a backup
    backup = "/tmp/#{@name}.xcodeproj.bak"
    File.expects(:exists?).with(backup).returns(true)
    Kernel.expects(:system).with("rm -rf #{backup}")
    Kernel.expects(:system).with("cp -R #{@project_path} #{backup}")
    @project.project_data.expects(:writeToFile_atomically).with(@data_path, true)
    @project.save
  end
  
  it "should return an object for a given name" do
    @project.object_for_name('Baz').should == @object
    @project.object_for_name('foo').should.be nil
  end
  
  it "should return an object for a given type and name" do
    @project.object_for_type_and_name('PBXNativeTarget', 'Baz').should == @object
    @project.object_for_type_and_name('PBXBuildPhase', 'Baz').should.be nil
  end
  
  it "should return an object for the main target" do
    @project.object_for_project_target.should == @object
  end
  
  it "should return an object for a given id" do
    @project.object_for_id(@object_id).should == @object
    @project.object_for_id('DOES_NOT_EXIST').should.be nil
  end
  
  it "should add an object to the objects" do
    id, values = 'SOME_ID'.to_ns, { 'name' => 'some blah' }.to_ns
    @project.add_object(id, values)
    @project.object_for_id(id).should == [id, values]
  end
  
  it "should add a build phase to the project target only once" do
    id, values = 'BUILD_PHASE_ID'.to_ns, { 'name' => 'some blah' }.to_ns
    @project.add_object(id, values)
    @project.add_build_phase_to_project_target(id)
    @project.object_for_project_target.last['buildPhases'].should == [id]

    @project.add_build_phase_to_project_target(id)
    @project.object_for_project_target.last['buildPhases'].length.should.be 1
  end
  
  it "should add an object to a copy build phase" do
    id, values = 'BUILD_PHASE_ID'.to_ns, { 'name' => 'some blah', 'files' => [].to_ns }.to_ns
    @project.add_object(id, values)
    @project.add_build_phase_to_project_target(id)
    
    @project.add_object_to_build_phase(@object_id, id)
    @project.object_for_id(id).last['files'].should == [@object_id]
  end
  
  it "should generate UUIDs" do
    @project.generate_uuid.length.should.be 24
  end
  
  # This is a hack for the test if it generates a unique object id.
  # I couldn't find another way to first generate a dup and the second time a good one...
  def mock_generate_uuid
    Xcode.class_eval do
      alias_method :original_generate_uuid, :generate_uuid
      def generate_uuid
        generate_uuid_counter
        if @never_run.nil?
          @never_run = false
          '519A79DB0CC8AE6B00CBE85D'
        else
          '519A79DB0CC8AE6B00CBE85F'
        end
      end
    end
  end
  
  def unmock_generate_uuid
    Xcode.class_eval do
      alias_method :generate_uuid, :original_generate_uuid
    end
  end
  
  it "should generate a non-duplicate object id" do
    objects = {'519A79DB0CC8AE6B00CBE85D' => 1, '519A79DB0CC8AE6B00CBE85E' => 2}
    @project.expects(:objects).returns(objects)
    @project.expects(:generate_uuid_counter).times(2)
    mock_generate_uuid # set the hack
    @project.generate_object_id
    unmock_generate_uuid # unset the hack
  end
  
  # it "should create a new framework copy build phase" do
  #   # FIXME: until we generate id's this is just a lame test
  #   Xcode::NEW_COPY_FRAMEWORKS_BUILD_PHASE = @object
  #   @project.new_framework_copy_build_phase.should == @object
  # end
  
  it "should add a framework" do
    name = 'BlaBla.framework'
    path = '/foo/BlaBla.framework'
    
    before = @project.objects.length
    framework_obj, fileref_obj = @project.add_framework(name, path)
    @project.objects.length.should.be(before + 2)
    
    framework_obj.last.should == {
      'isa' => 'PBXFileReference',
      'lastKnownFileType' => 'wrapper.framework',
      'name' => name,
      'path' => path,
      'sourceTree' => '<absolute>'
    }.to_ns
    
    fileref_obj.last.should == {
      'fileRef' => framework_obj.first,
      'isa' => 'PBXBuildFile'
    }.to_ns
    
    linked_frameworks = @project.object_for_name('Linked Frameworks')
    linked_frameworks.last['children'].should.include framework_obj.first
  end
  
  it "should add a framework as absolute" do
    framework_obj, fileref_obj = @project.add_framework('BlaBla.framework', '/foo/BlaBla.framework')
    framework_obj.last['sourceTree'].should == '<absolute>'
  end
  
  it "should add a framework as relative (group)" do
    framework_obj, fileref_obj = @project.add_framework('BlaBla.framework', 'vendor/frameworks/BlaBla.framework')
    framework_obj.last['sourceTree'].should == '<group>'
  end
  
  it "should list the frameworks that it includes" do
    framework_obj, fileref_obj = @project.add_framework('BlaBla.framework', '/foo/BlaBla.framework')
    @project.frameworks.should == [framework_obj]
  end
  
  it "should change the path of a framework used in the project" do
    framework_obj, fileref_obj = @project.add_framework('RubyCocoa.framework', '/foo/RubyCocoa.framework')
    id = framework_obj.first
    
    framework_path = 'vendor/RubyCocoa.framework'
    @project.change_framework_location('RubyCocoa.framework', framework_path)
    
    @project.object_for_id(id).last['path'].should == framework_path
    @project.object_for_id(id).last['sourceTree'].should == '<group>'
  end
  
  it "should change the path of the RubyCocoa framework" do
    framework_path = 'vendor/RubyCocoa.framework'
    @project.expects(:change_framework_location).with('RubyCocoa.framework', framework_path)
    @project.change_rubycocoa_framework_location(framework_path)
  end
  
  it "should bundle a framework with the application" do
    framework_obj, fileref_obj = @project.add_framework('BlaBla.framework', '/foo/BlaBla.framework')
    id = framework_obj.first
    
    @project.bundle_framework('BlaBla.framework')
    
    build_phases = @project.object_for_project_target.last['buildPhases']
    build_phases.length.should.be 1
    @project.object_for_id(build_phases.first).last['name'].should == 'Copy Frameworks'
    
    build_phase_id = @project.object_for_id(build_phases.first).last['files'].first
    build_phase_id, build_phase = @project.object_for_id(build_phase_id)
    build_phase['fileRef'].should == id
  end
  
  it "should bundle the RubyCocoa framework with the application" do
    @project.expects(:bundle_framework).with('RubyCocoa.framework')
    @project.bundle_rubycocoa_framework
  end

end
