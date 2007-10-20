ENV['RUBYCOCOA_ENV'] = 'test'
ENV['RUBYCOCOA_ROOT'] = File.expand_path('../../', __FILE__)

require 'rubygems'
require 'rucola'

require File.expand_path('../../config/boot', __FILE__)
require "test/unit"