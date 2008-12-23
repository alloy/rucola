#require "rubygems"
require "mocha"

require "test/spec"
# Tmp fix:
module Kernel
  def context(name, superclass=Test::Unit::TestCase, klass=Test::Spec::TestCase, &block)     # :doc:
    (Test::Spec::CONTEXTS[name] ||= klass.new(name, nil, superclass)).add(&block)
  end

  def xcontext(name, superclass=Test::Unit::TestCase, &block)     # :doc:
    context(name, superclass, Test::Spec::DisabledTestCase, &block)
  end

  def shared_context(name, &block)
    Test::Spec::SHARED_CONTEXTS[name] << block
  end

  alias :describe :context
  alias :xdescribe :xcontext
  alias :describe_shared :shared_context

  # private :context, :xcontext, :shared_context
  # private :describe, :xdescribe, :describe_shared
end

#framework "cocoa"

# # suppress all the warnings about contsants being re-initialized when re-requiring the same lib
# $VERBOSE = nil

$:.unshift File.expand_path('../../lib', __FILE__)

require "rucola/support"

# FIXTURES = File.expand_path('../fixtures/', __FILE__)
# $TESTING = true

require 'pathname'
RUCOLA_ROOT = Pathname.new(File.expand_path(File.dirname(__FILE__)))
RUCOLA_ENV = 'test'

# require 'rucola/rucola_support'
# require 'rucola/test_helper'
# 
# # Don't know if this is good enough yet to add to the helpers for apps.
# # Need to see what assert_difference does.
# module Test::Spec::Rucola
#   module ShouldChange
#     def change(string, difference = 1, obj = nil)
#       initial_value = (obj.nil? ? eval(string) : obj.instance_eval(string))
#       @object.call
#       (obj.nil? ? eval(string) : obj.instance_eval(string)).should == initial_value + difference
#     end
#   end
#   module ShouldNotChange
#     def change(string, obj = nil)
#       initial_value = (obj.nil? ? eval(string) : obj.instance_eval(string))
#       @object.call
#       (obj.nil? ? eval(string) : obj.instance_eval(string)).should == initial_value
#     end
#   end
# end
# Test::Spec::Should.send(:include, Test::Spec::Rucola::ShouldChange)
# Test::Spec::ShouldNot.send(:include, Test::Spec::Rucola::ShouldNotChange)
# 
# require 'tmpdir'
# require 'fileutils'
# 
# module Tmp
#   def self.included(base)
#     base.send(:before) { Tmp.setup }
#     base.send(:after)  { Tmp.teardown }
#   end
#   
#   def self.setup
#     FileUtils.mkdir_p(path)
#   end
#   
#   def self.teardown
#     FileUtils.rm_rf(path)
#   end
#   
#   def self.path
#     File.join(Dir.tmpdir, 'rucola')
#   end
# end
