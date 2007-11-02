require 'osx/cocoa'

module Rucola
  class RCDocument < OSX::NSDocument
    def makeWindowControllers
      @@_window_controller ||= Object.const_get("#{self.class.name.to_s.camel_case}Controller")
      addWindowController @@_window_controller.alloc.init
    end
  end
end
