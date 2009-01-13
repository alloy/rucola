require 'rucola/support'

module Rucola
  module Initializer
    class << self
      # Assign a Rucola::Configuration instance.
      attr_writer :configuration
      
      # Returns the current Rucola::Configuration instance.
      def configuration
        @configuration ||= Configuration.new
      end
      
      def run
        yield configuration
      end
      
      def start_application!
        NSApplicationMain(0, nil)
      end
      
      def process
        load_environment
        load_plugins
        set_load_path
        load_frameworks
        load_application_files
      end
      
      def load_environment
        require RCApp.root_path + "config/environment.rb"
        require RCApp.root_path + "config/environments/#{RCApp.env}.rb"
      end
      
      # Set the <tt>$LOAD_PATH</tt> based on the value of
      # Configuration#load_paths. Duplicates are removed.
      def set_load_path
        configuration.load_paths.reverse.each { |dir| $LOAD_PATH.unshift dir }
        $LOAD_PATH.uniq!
      end
      
      # Loads all frameworks specified by the Configuration#frameworks list.
      def load_frameworks
        configuration.frameworks.each { |f| framework(f) }
      end
      
      # Loads all application files, which are Ruby source files (.rb) found in:
      # <tt>RCApp.controllers_path</tt>, <tt>RCApp.models_path</tt>, and <tt>RCApp.views_path</tt>.
      def load_application_files
        %w{ controllers_path models_path views_path }.map do |type|
          Dir.glob("#{ RCApp.send(type) }/*.rb")
        end.flatten.each { |file| require file }
      end
      
      # Loads all plugins in <tt>RCApp.plugins_path</tt>.
      #
      # As each plugin discovered in <tt>RCApp.plugins_path</tt> is initialized:
      # * its +lib+ directory, if present, is added to the load path # TODO
      # * <tt>init.rb</tt> is evaluated, if present
      def load_plugins
        RCApp.plugins_path.children.each do |plugin|
          init = plugin + 'init.rb'
          require(init) if init.exist?
        end
      end
    end
  end
  
  class Configuration
    # The list of Objective-C frameworks that should be loaded.
    # (Defaults to <tt>Cocoa<tt/>)
    attr_accessor :frameworks
    
    # An array of additional paths to prepend to the load path. By default,
    # all +app+, +lib+, and +vendor+ paths are included in this list.
    attr_accessor :load_paths
    
    def initialize
      self.frameworks = default_frameworks
      self.load_paths = default_load_paths
    end
    
    private
    
    def default_frameworks
      ['Cocoa']
    end
    
    def default_load_paths
      %w{
        app/controllers
        app/models
        app/views
        lib
        vendor
      }.map { |dir| (RCApp.root_path + dir).to_s }
    end
  end
end