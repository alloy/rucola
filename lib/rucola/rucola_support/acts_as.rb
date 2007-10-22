require 'osx/cocoa'
require 'rucola/rucola_support/objc_core_ext/nsobject'

module Rucola
  module ActsAs
    # When you define a new ActsAsFoo module you need to register it so Rucola knows of it.
    # To do this you call +register_acts_as+ and pass it the name of the module in snake case.
    # Rucola will then generate the acts_as_foo class method in OSX::NSObject,
    # so any subclass of OSX::NSObject will have the acts_as_foo method available.
    #
    # You can also give it an optional block which will be instance_eval'ed after the object has been
    # initialized. This is where you would call any setup methods if necessary.
    #
    #   module Rucola::ActsAs
    #
    #     # defines a class method acts_as_foo and yields the fresh initialized instance as self
    #     register_acts_as :notifiable do
    #       # call the method that starts the acts_as_notifiable work
    #       _register_notifications
    #     end
    #
    #     module Notifiable
    #
    #       # code
    #
    #       def _register_notifications
    #         # after initialization setup code
    #       end
    #
    #     end
    #   end
    def self.register_acts_as(extension_name, &block)
      method_name = "acts_as_#{extension_name}".to_sym
      
      OSX::NSObject.class.instance_eval do
        # define the acts_as_foo class method
        define_method(method_name) do
          # add the initialize proc to the initialize hooks.
          _rucola_register_initialize_hook(block) if block_given?
          
          # get the name of the module and include it
          extension = Rucola::ActsAs::const_get(extension_name.to_s.camel_case)
          include extension
        end
      end
    end
  end
end
