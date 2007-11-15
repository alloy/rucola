require 'osx/cocoa'

module Rucola
  # Abstract base class for Rucola plugins
  # override the methods in your plugin to get code run at appropriate times
  class Plugin
    @@plugins = []
    
    def self.plugins
      @@plugins
    end
    
    def self.inherited(subclass)
      @@plugins << subclass.new
    end
    
    def before_boot(initializer); end
    def after_boot(initializer); end
    def before_process(initializer); end
    def after_process(initializer); end
  end
end