$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rucola_support/rc_app'
require 'rucola_support/initialize_hooks'
require 'rucola_support/core_ext'
require 'rucola_support/controllers'
require 'rucola/rucola_support/notifications'