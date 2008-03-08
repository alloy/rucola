# Dir[File.dirname(__FILE__) + "/ruby/*.rb"].sort.each do |path|
#   filename = File.basename(path)
#   require "rucola_support/core_ext/ruby/#{filename}"
# end

$:.unshift(File.dirname(__FILE__))

require 'ruby/file'
require 'ruby/object'
require 'ruby/string'