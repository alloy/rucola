require 'fileutils'
include FileUtils

require 'rubygems'
required = %w[rake hoe newgem rubigen]
class << required
  def to_sentence
    "#{self[0...-1].join(', ')}, and #{self[-1]}"
  end
end
required.each do |gem_name|
  begin
    require gem_name
  rescue LoadError => e
    puts "[!] In order to run this Rakefile you need the following gems: #{required.to_sentence}"
    puts
    puts "    Couldn't load: `#{gem_name}' (#{e.message})"
    puts "    Please install the required gem: gem install #{gem_name}"
    exit
  end
end

$:.unshift(File.join(File.dirname(__FILE__), %w[.. lib]))

require 'rucola'