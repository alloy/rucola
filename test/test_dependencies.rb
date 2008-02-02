require File.expand_path('../test_helper', __FILE__)
require 'rucola/dependencies'

Rucola::Dependencies.verbose = false
$LOAD_PATH.unshift(File.join(FIXTURES, 'dependencies/'))

module DependenciesSpecHelper
  def self.included(klass)
    klass.class_eval do
      after do
        @dep = nil
        FileUtils.rm_rf(copied_deps_path)
      end
    end
  end
  
  private
  
  def deps_path(file = '')
    File.join(FIXTURES, 'dependencies', file)
  end
  
  def copied_deps_path(file = '')
    File.join(TMP_PATH, 'copied_dependencies', file)
  end
  
  def stubbed_equal_required_files
    klass = Rucola::Dependencies::RequiredFile
    klass.any_instance.stubs(:resolve_relative_and_full_path).returns(['path/foo.rb', '/full/path/foo.rb'])
    [klass.new(''), klass.new('')]
  end
end

describe "Dependencies::Dependency" do
  include DependenciesSpecHelper
  
  before do
    @dep = Rucola::Dependencies::Dependency.new('foo')
  end
  
  it "should initialize" do
    @dep.should.be.instance_of Rucola::Dependencies::Dependency
    @dep.name.should == 'foo'
  end
  
  it "should be able to require it" do
    Kernel.expects(:require).with('foo')
    @dep.require!
  end
  
  it "should activate a specific gem if a version is specified" do
    Kernel.stubs(:require)
    
    @dep.instance_variable_set(:@version, '1.1.1')
    Gem.expects(:activate).with('foo', true, '1.1.1')
    @dep.require!
  end
  
  it "should be able to resolve the files it needs" do
    lambda { @dep.resolve! }.should.not.change('$LOADED_FEATURES.dup')
    required_files = @dep.required_files.map {|f| f.full_path }.sort
    required_files.should == [deps_path('foo.rb'), deps_path('foo/bar.rb'), deps_path('foo/baz.rb')]
  end
  
  it "should be able to copy to the specified destination path" do
    @dep.resolve!
    @dep.copy_to(copied_deps_path)
    %w{ foo.rb foo/bar.rb foo/baz.rb }.each do |file|
      File.exist?(copied_deps_path(file)).should.be true
    end
  end
  
  it "should be possible to only copy `gem` lib files" do
    should_copy_types(:gem)
    @dep.copy_to(copied_deps_path, :types => [:gem])
  end
  
  it "should be possible to only copy `standard` lib files" do
    should_copy_types(:standard)
    @dep.copy_to(copied_deps_path, :types => [:standard])
  end
  
  it "should be possible to only copy `gem` libs" do
    should_copy_types(:other)
    @dep.copy_to(copied_deps_path, :types => [:other])
  end
  
  it "should be possible to combine the types of libs to be copied" do
    should_copy_types(:other, :gem)
    @dep.copy_to(copied_deps_path, :types => [:other, :gem])
  end
  
  it "should be possible to get a list of required files of only certain types" do
    dep = Rucola::Dependencies::Dependency.new('requires_fileutils')
    dep.resolve!
    dep.required_files_of_types(:other).all? {|f| f.should.be.other_lib }
    dep.required_files_of_types(:standard).all? {|f| f.should.be.standard_lib }
  end
  
  private
  
  def should_copy_types(*types)
    keys = [:gem, :other, :standard]
    files = []
    keys.each do |type|
      file = mock(type.to_s)
      file.stubs({ :full_path => '/some/path', :gem_lib? => false, :standard_lib? => false, :other_lib? => false }.merge({ "#{type}_lib?".to_sym => true }))
      if types.include?(type)
        file.expects(:copy_to).times(1).with(copied_deps_path)
      else
        file.expects(:copy_to).times(0)
      end
      files << file
    end
    @dep.instance_variable_set(:@required_files, files)
  end
end

describe "Dependencies" do
  include DependenciesSpecHelper
  
  before do
    @deps = Rucola::Dependencies.new
    @deps.dependency 'foo'
    @deps.dependency 'rubynode', '0.1.3'
    @deps.dependency 'fileutils'
    @deps.resolve!
  end
  
  it "should create a Dependency instance when a dependency is specified" do
    lambda { @deps.dependency('hpricot') }.should.change("@deps.dependencies.length", +1, self)
  end
  
  it "should be able to require all the dependencies" do
    @deps.dependencies.each { |dep| dep.expects(:require!) }
    @deps.require!
  end
  
  it "should be able to resolve all the files needed by the dependencies" do
    @deps.dependencies.each do |dep|
      dep.required_files.should.not.be.empty
    end
  end
  
  it "should be able to copy to the specified destination path" do
    @deps.copy_to(copied_deps_path)
    %w{ foo.rb rubynode.rb fileutils.rb }.each do |file|
      File.exist?(copied_deps_path(file)).should.be true
    end
  end
  
  it "should be possible to only copy specific types of files" do
    @deps.dependencies.each do |dep|
      dep.expects(:copy_to).with(copied_deps_path, { :types => [:gem, :other]})
    end
    @deps.copy_to(copied_deps_path, :types => [:gem, :other])
  end
  
  it "should be able to return a complete list of unique required files" do
    files = stubbed_equal_required_files
    @deps.dependencies.stubs(:collect).returns([[files.first], [files.last]])
    
    @deps.required_files.length.should.be 1
  end
end

describe "Dependencies::Dependency::RequiredFile" do
  include DependenciesSpecHelper
  
  it "should be able to compare to another instance" do
    files = stubbed_equal_required_files
    files.first.should == files.last
  end
end