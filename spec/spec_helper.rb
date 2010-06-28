# encoding: UTF-8
require 'rubygems'
require 'bacon'

# gem 'mocha-macruby'
require 'mocha'
require 'mocha-on-bacon'

require 'tempfile'
require 'fileutils'

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
  
  def file(path, encoding)
    template = File.join('expected/Übercøøl', path)
    output   = File.join(@destination, path)
    
    File.should.exist output
    
    output_content = File.read(output)
    output_content.force_encoding(encoding)
    
    expected_content = read_fixture(template)
    expected_content.force_encoding(encoding)
    
    output_content.encode('UTF-8').should == expected_content.encode('UTF-8')
  end
  
  def dir(path)
    File.should.exist path
    File.should.be.directory path
  end
  
  def run_generator(generator, name, source_root)
    generator.stubs(:source_root).returns(source_root)
    ARGV[0] = @destination = File.join(Dir.tmpdir, name)
    generator.start
    yield
  ensure
    mocha_teardown
    # p @destination
    FileUtils.rm_rf @destination
  end
end

# Fixture

class XCodeTemplateContext
  def PROJECTNAME
    'Übercøøl'
  end
  alias :PROJECTNAMEASXML :PROJECTNAME
end