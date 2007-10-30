require 'osx/cocoa'

module Rucola
  class RCWindowController < OSX::NSWindowController
    # Loads the nib that corresponds to this subclass.
    # So for instance a class PreferencesWindowController,
    # will look for a nib in: app/views/Preferences.nib
    def init
      self if self.initWithWindowNibPath_owner(Rucola::RCApp.path_for_view(self), self)
    end
  end
end
