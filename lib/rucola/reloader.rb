require 'rucola/fsevents'
require 'rubynode'

module Rucola
  # The +Reloader+ watches the app/controllers path and reloads
  # a class if it notices that a file has been changed.
  module Reloader
    class << self
      # Start watching app/controllers for a file modification and reload that class.
      def start!
        Rucola::FSEvents.start_watching(Rucola::RCApp.controllers_path, Rucola::RCApp.models_path) do |events|
          events.each { |event| reload(event.last_modified_file) }
        end
      end
      
      # Reload a file (class).
      def reload(file)
        klass = File.constantize(file)
        # FIXME: hack!
        begin
          File.read(file).parse_to_nodes
          
          OSX.NSLog "Reloading class #{klass.name}:"

          i_methods = klass.instance_methods(false)
          OSX.NSLog "- Undefining instance methods: #{i_methods.inspect}"
          i_methods.each { |mname| klass.send(:undef_method, mname) }

          c_methods = klass.original_class_methods
          OSX.NSLog "- Undefining class methods: #{c_methods.inspect}"
          c_methods.each { |mname| klass.metaclass.send(:undef_method, mname) }

          Kernel.load(file)
        rescue SyntaxError => e
          OSX.NSLog "WARNING: Reloading the class #{klass.name} would have caused a parse error:\n#{e.message}"
        end
      end
    end
  end
end