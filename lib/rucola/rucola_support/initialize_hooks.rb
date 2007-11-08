module Rucola
  module InitializeHooks
    module ClassMethods
      # Adds the given proc to the initialize hooks queue,
      # which will be ran after object initialization.
      def _rucola_register_initialize_hook(hook)
        (@_rucola_initialize_hooks ||= []).push hook
      end
    end
  
    # Calls all the hooks that have been added to the queue.
    #
    # It will also call the method +after_init+, but only if you have defined it.
    # Create this method to do work that you would normally do in +initialize+ or +init+.
    def initialize
      # get the hooks, if they exist let them all do their after initialization work.
      hooks = self.class.instance_variable_get(:@_rucola_initialize_hooks)
      hooks.each { |hook| self.instance_eval(&hook) } unless hooks.nil?
      
      # also call after_init for custom initialization code.
      send :after_init if respond_to? :after_init # TODO: test
    end
  
    def self.included(base) # :nodoc
      base.extend(ClassMethods)
    end
  end
end