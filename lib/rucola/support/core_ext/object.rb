module Rucola
  module CoreExt
    module Object
      # Returns a class's metaclass.
      #
      #   class FooBar; end
      #   p FooBar.metaclass # => #<Class:FooBar>
      def metaclass
        class << self; self; end
      end
      
      # Returns an array of all the class methods that were added by extending the class.
      #
      #  class FooBar; end
      #
      #  module Baz
      #    def a_new_class_method; end
      #  end
      #  FooBar.extend(Baz)
      #
      #  FooBar.extended_class_methods # => ['a_new_class_method']
      def extended_class_methods
        metaclass.included_modules.map { |mod| mod.instance_methods }.flatten.uniq
      end
      
      # Returns an array of all the class methods that were defined in this class
      # without the ones that were defined in it's superclasses.
      #
      #  class FooBar
      #    def self.a_original_class_method
      #    end
      #  end
      #
      #  class FooBarSubclass < FooBar
      #    def self.a_original_class_method_in_a_subclass
      #    end
      #  end
      #
      #  FooBarSubclass.own_class_methods # => ['a_original_class_method_in_a_subclass']
      def own_class_methods
        metaclass.instance_methods - superclass.metaclass.instance_methods
      end
      
      # Returns an array of all the class methods that were defined in only this class,
      # so without class methods from any of it's superclasses or from extending it.
      def original_class_methods
        own_class_methods - extended_class_methods
      end
    end
  end
end

Object.send :extend, Rucola::CoreExt::Object