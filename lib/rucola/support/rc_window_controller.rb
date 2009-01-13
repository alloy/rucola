module Rucola
  class RCWindowController < NSWindowController
    include RCApp
    
    # Loads the nib that corresponds to this subclass.
    # So for instance a class PreferencesWindowController,
    # will look for a nib in: app/views/Preferences.nib
    def init
      self if initWithWindowNibPath(path_for_view(self), owner: self)
    end
  end
end
