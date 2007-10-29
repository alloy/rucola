require 'osx/cocoa'

module Rucola
  class RCWindowController < OSX::NSWindowController
    # Loads the nib that corresponds to this subclass.
    # So for instance a class PreferencesWindowController,
    # will look for a nib in: app/views/Preferences.nib
    def init
      self if self.initWithWindowNibPath_owner((RUBYCOCOA_ROOT + "app/views/#{self.class.to_s.sub(/Controller$/, '')}.nib").to_s, self)
    end
  end
end
