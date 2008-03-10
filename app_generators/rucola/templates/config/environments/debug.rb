# Perform any debug specific task here.

Rucola::Initializer.run do |config|
  # The debugger allows you to easily set breakpoints and debug them.
  # See the documentation from ruby-debug for its usage:
  # http://www.datanoise.com/ruby-debug/
  
  config.use_debugger = true
  
  # Turning on the reloader will start a fsevent loop which watches the files in app/ for changes
  # and try to reload any classes that have been saved while the app is running.
  # It could however lead to erratic behaviour and it's therefor turned off by default.
  #
  # config.use_reloader = true
end