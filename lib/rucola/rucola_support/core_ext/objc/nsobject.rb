require 'osx/cocoa'

class OSX::NSObject
  
  #alias_method :_before_rucola_adds_initialize_hook, :initialize
  # FIXME: Is it ok to use #initialize?
  def initialize
    # get the hooks, if they exist let them all do their after initialization work.
    hooks = self.class.instance_variable_get(:@_rucola_initialize_hooks)
    hooks.each { |hook| self.instance_eval(&hook) } unless hooks.nil?
    
    # call original initialize
    #_before_rucola_adds_initialize_hook
  end
  
  # Adds the given proc to the initialize hooks queue,
  # which will be ran after object initialization.
  def self._rucola_register_initialize_hook(hook)
    (@_rucola_initialize_hooks ||= []).push hook
  end
  
end