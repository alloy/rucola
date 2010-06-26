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
end
