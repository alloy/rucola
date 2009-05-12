module Kernel
  def debugger(steps = 1); end
end

module Rucola
  module Debugger
    def self.use! #:nodoc:
      Kernel.module_eval do
        # If enabled in the Configuration (default in `debug` environment is on), calling #debugger will try to load the ruby-debug gem.
        # In other modes however any call to #debugger will be ignored.
        # However, for performance reasons you still might want to take out any calls in a release build.
        def debugger(steps = 1)
          rucola_load_ruby_debug(steps)
        end
        
        private
        
        def rucola_load_ruby_debug(steps) #:nodoc:
          require 'ruby-debug'
          debugger(steps)
        rescue LoadError
          log.error "The ruby-debug gem is needed to be able to use the debugger, but it wasn't found."
        end
      end
    end
  end
end