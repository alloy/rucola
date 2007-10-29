module Rucola
  module InitializeHooks
    module ClassMethods
      # Adds the given proc to the initialize hooks queue,
      # which will be ran after object initialization.
      def _rucola_register_initialize_hook(hook)
        (@_rucola_initialize_hooks ||= []).push hook
      end
    end
  
    def initialize
      # get the hooks, if they exist let them all do their after initialization work.
      hooks = self.class.instance_variable_get(:@_rucola_initialize_hooks)
      hooks.each { |hook| self.instance_eval(&hook) } unless hooks.nil?
    end
  
    def self.included(base) # :nodoc
      base.extend(ClassMethods)
    end
  end
end