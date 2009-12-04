$:.unshift File.expand_path('../../lib', __FILE__)
require 'rucola'

require File.expand_path('../../vendor/bacon/lib/bacon', __FILE__)
# require 'mocha'

# This has to be called in order to instantiate windows etc.
framework 'appkit'
app = NSApplication.sharedApplication