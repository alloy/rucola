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
    
    def self.after_launch
      plugins.each {|p| p.after_launch }
    end
    
    def before_boot; end
    def after_boot; end
    def before_process(initializer); end
    def after_process(initializer); end
    def after_launch; end
  end
  
  # This class is used to be able to run hooks when the app has started.
  class PluginRunner < OSX::NSObject
    def initialize
      center = OSX::NSNotificationCenter.defaultCenter
      center.addObserver_selector_name_object(self, :after_launch, OSX::NSApplicationDidFinishLaunchingNotification, nil)
    end

    def after_launch(notification)
      Rucola::Plugin.after_launch
    end
    
    @instance = self.alloc.init
  end
end