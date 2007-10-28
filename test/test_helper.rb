require "rubygems"
require "test/unit"
require "test/spec"
require "mocha"

$:.unshift File.expand_path('../../lib', __FILE__)

FIXTURES = File.expand_path('../fixtures/', __FILE__)
$TESTING = true
