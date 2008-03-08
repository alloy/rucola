# Dir[File.dirname(__FILE__) + "/objc/*.rb"].sort.each do |path|
#   filename = File.basename(path)
#   require "rucola_support/core_ext/objc/#{filename}"
# end

$:.unshift(File.dirname(__FILE__))

require 'objc/nsimage'
require 'objc/nsobject'