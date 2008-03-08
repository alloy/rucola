module Kernel
  if Rucola::RCApp.debug?
    # When in `debug` mode, calling #debugger will try to load the ruby-debug gem.
    # In other modes however any call to #debugger will be ignored.
    # However, for performance reasons you still might want to take out any calls in a release build.
    def debugger(steps = 1)
      _rucola_load_ruby_debug(steps)
    end
    def _rucola_load_ruby_debug(steps)
      require 'ruby-debug'
      debugger(steps)
    rescue LoadError
      puts "The ruby-debug gem is needed to be able to use the debugger but wasn't found."
    end
    private :_rucola_load_ruby_debug
  else
    def debugger(steps = 1); end
  end
end
