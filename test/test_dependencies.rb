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
  
  it "should be possible to only copy `gem` libs" do
    deps_that_expect_copy(:gem)
    @deps.copy_to(copied_deps_path, :types => [:gem])
  end
  
  it "should be possible to only copy `standard` libs" do
    deps_that_expect_copy(:standard)
    @deps.copy_to(copied_deps_path, :types => [:standard])
  end
  
  it "should be possible to only copy `other` libs" do
    deps_that_expect_copy(:other)
    @deps.copy_to(copied_deps_path, :types => [:other])
  end
  
  it "should be possible to combine the types of libs to be copied" do
    deps_that_expect_copy(:other, :gem)
    @deps.copy_to(copied_deps_path, :types => [:other, :gem])
  end
  
  private
  
  def deps_that_expect_copy(*keys)
    types = {:other => 0, :gem => 1, :standard => 2}
    keys.each { |key| @deps.dependencies[types[key]].expects(:copy_to).times(1) }
    (types.keys - keys).each { |key| @deps.dependencies[types[key]].expects(:copy_to).times(0) }
  end
end