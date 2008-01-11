require 'rucola/fsevents'

module Rucola
  # The +Reloader+ watches the app/controllers path and reloads
  # a class if it notices that a file has been changed.
  module Reloader
    class << self
      # Start watching app/controllers for a file modification and reload that class.
      def start!
        Rucola::FSEvents.start_watching(Rucola::RCApp.controllers_path) do |events|
          events.each { |event| reload(event.last_modified_file) }
        end
      end
      
      # Reload a file (class).
      def reload(file)
        klass = File.constantize(file)
        OSX.NSLog "Reloading class #{klass.name}:"
        
        i_methods = klass.instance_methods(false)
        OSX.NSLog "- Undefining instance methods: #{i_methods.inspect}"
        i_methods.each { |mname| klass.send(:undef_method, mname) }
        
        c_methods = klass.original_class_methods
        OSX.NSLog "- Undefining class methods: #{c_methods.inspect}"
        c_methods.each { |mname| klass.metaclass.send(:undef_method, mname) }
        
        Kernel.load(file)
      end
    end
  end
end