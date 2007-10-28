$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
  
require 'rucola_support/core_ext'
require 'rucola_support/window_controller'
require 'rucola/rucola_support/acts_as'