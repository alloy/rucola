require "rubygems"
require "test/unit"
require "test/spec"
require "mocha"
require 'osx/cocoa'

# suppress all the warnings about contsants being re-initialized when re-requiring the same lib
$VERBOSE = nil

$:.unshift File.expand_path('../../lib', __FILE__)

FIXTURES = File.expand_path('../fixtures/', __FILE__)
$TESTING = true

require 'pathname'
RUBYCOCOA_ROOT = Pathname.new(File.expand_path(File.dirname(__FILE__)))
RUBYCOCOA_ENV = 'test'
TMP_PATH = File.expand_path('../../tmp/', __FILE__)

require 'rucola/rucola_support'
require 'rucola/test_helper'

# Don't know if this is good enough yet to add to the helpers for apps.
# Need to see what assert_difference does.
module Test::Spec::Rucola
  module ShouldChange
    def change(string, difference = 1, obj = nil)
      initial_value = (obj.nil? ? eval(string) : obj.instance_eval(string))
      @object.call
      (obj.nil? ? eval(string) : obj.instance_eval(string)).should == initial_value + difference
    end
  end
  module ShouldNotChange
    def change(string, obj = nil)
      initial_value = (obj.nil? ? eval(string) : obj.instance_eval(string))
      @object.call
      (obj.nil? ? eval(string) : obj.instance_eval(string)).should == initial_value
    end
  end
end
Test::Spec::Should.send(:include, Test::Spec::Rucola::ShouldChange)
Test::Spec::ShouldNot.send(:include, Test::Spec::Rucola::ShouldNotChange)
