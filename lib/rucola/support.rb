require "rucola/support/core_ext"

module Rucola
  autoload :Configuration,      'rucola/initializer'
  autoload :FSEvents,           'rucola/fsevents'
  autoload :InfoPlist,          'rucola/info_plist'
  autoload :Initializer,        'rucola/initializer'
  autoload :Log,                'rucola/log'
  autoload :RCApp,              'rucola/support/rc_app'
  autoload :RCController,       'rucola/support/rc_controller'
  autoload :RCWindowController, 'rucola/support/rc_window_controller'
end