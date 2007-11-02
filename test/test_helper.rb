require "rubygems"
require "test/unit"
require "test/spec"
require "mocha"
require 'osx/cocoa'

$:.unshift File.expand_path('../../lib', __FILE__)

FIXTURES = File.expand_path('../fixtures/', __FILE__)
$TESTING = true

require 'rucola/rucola_support'
require 'rucola/test_helper'