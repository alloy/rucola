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
        klass = File.to_const(file)
        begin
          File.read(file).parse_to_nodes
          
          log.debug "Reloading class #{klass.name}"
          
          klass.instance_methods(false).each do |mname|
            klass.send(:undef_method, mname)
          end
          klass.original_class_methods.each do |mname|
            klass.metaclass.send(:undef_method, mname)
          end
          
          Kernel.load(file)
        rescue SyntaxError => e
          log.error "WARNING: Reloading the class #{klass.name} would have caused a parse error:\n#{e.message}"
        end
      end
    end
  end
end