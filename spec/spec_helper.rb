require 'rubygems'
require 'bacon'

gem 'mocha-macruby'
require 'mocha'
require 'mocha-on-bacon'

$:.unshift File.expand_path('../../lib', __FILE__)

Bacon.summary_on_exit

FIXTURE_ROOT = File.expand_path('../fixtures', __FILE__)

class Bacon::Context
  def fixture(name)
    File.join(FIXTURE_ROOT, name)
  end

  def read_fixture(name)
    File.read(fixture(name))
  end
end
