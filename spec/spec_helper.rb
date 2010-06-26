require 'rubygems'
require 'bacon'

gem 'mocha-macruby'
require 'mocha'
require 'mocha-on-bacon'

ROOT = File.expand_path('../../', __FILE__)
FIXTURE_ROOT = File.join(ROOT, 'spec/fixtures')
$:.unshift File.join(ROOT, 'lib')

Bacon.summary_on_exit

class Bacon::Context
  def fixture(name)
    File.join(FIXTURE_ROOT, name)
  end

  def read_fixture(name)
    File.read(fixture(name))
  end
  
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
  
  require 'fileutils'
  include FileUtils
  
  def run_generator(generator, name, source_root)
    generator.stubs(:source_root).returns(source_root)
    ARGV[0] = @destination = File.join(Dir.tmpdir, name)
    generator.start
    yield
  ensure
    mocha_teardown
    rm_rf @destination
  end
end

# Fixture

class XCodeTemplateContext
  def PROJECTNAME
    'Übercøøl'
  end
  alias :PROJECTNAMEASXML :PROJECTNAME
end