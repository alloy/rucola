require 'osx/cocoa'

class OSX::NSObject
  class << self
    alias_method :_inherited_before_rucola, :inherited
    
    def inherited(subclass)
      # First let RubyCocoa do it's magic!
      _inherited_before_rucola(subclass)
    
      # We only want to mixin modules into subclasses of classes
      # that start with 'Rucola::RC'.
      class_prefix = subclass.superclass.name.to_s[0..9]
      if class_prefix == 'Rucola::RC'
        subclass.class_eval do
          include Rucola::InitializeHooks
          include Rucola::Notifications
        end
      end
    end
  end
end