# require 'rucola/support/rc_app'
# require 'rucola_support/initialize_hooks'
# require 'rucola_support/core_ext'
# require 'rucola_support/controllers'
# require 'rucola_support/models'
# require 'rucola/rucola_support/notifications'

require "rucola/support/core_ext"

module Rucola
  autoload :InfoPlist, 'rucola/info_plist'
  autoload :Log,       'rucola/log'
  autoload :RCApp,     'rucola/support/rc_app'
end