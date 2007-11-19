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
    
    def self.before_boot
      plugins.each { |p| p.before_boot }
    end
    
    def self.after_boot
      plugins.each { |p| p.after_boot }
    end
    
    def self.before_process(initializer)
      plugins.each {|p| p.before_process(initializer) }
    end
    
    def self.after_process(initializer)
      plugins.each {|p| p.after_process(initializer) }
    end
    
    def before_boot; end
    def after_boot; end
    def before_process(initializer); end
    def after_process(initializer); end
  end
end