require 'rucola/support'

module Rucola
  module Initializer
    class << self
      # Returns the current Rucola::Configuration instance.
      def configuration
        @configuration ||= Configuration.new
      end
      
      # Yields the configuration that will be used by process to configure the
      # environment.
      #
      #   Rucola::Initializer.run do |config|
      #     config.framework 'WebKit'
      #     config.load_path '/Shared/Code'
      #     config.require 'a_shared_lib'
      #   end
      def run
        yield configuration
      end
      
      # Start the application. This is normally only called from the rb_main.rb
      # file.
      def start_application!
        NSApplicationMain(0, nil)
      end
      
      # Sets up everything as configured on the configuration.
      def process
        load_environment
        load_plugins
        set_load_path
        load_frameworks
        load_require_queue
        load_application_files
      end
      
      # Loads the environment files.
      #
      # Consider:
      #
      #   Rucola::RCApp.env # => debug
      #
      # In this case the following files would be loaded:
      #
      #   root/config/environment.rb
      #   root/config/environments/debug.rb
      def load_environment
        require RCApp.root_path + "config/environment.rb"
        require RCApp.root_path + "config/environments/#{RCApp.env}.rb"
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
      
      # Loads all libraries specified by the Configuration#require_queue list.
      def load_require_queue
        configuration.require_queue.each { |lib| require lib }
      end
      
      # Loads all application files, which are Ruby source files (.rb) found
      # in: <tt>RCApp.controllers_path</tt>, <tt>RCApp.models_path</tt>, and
      # <tt>RCApp.views_path</tt>.
      def load_application_files
        %w{ controllers_path models_path views_path }.map do |type|
          Dir.glob("#{ RCApp.send(type) }/*.rb")
        end.flatten.each { |file| require file }
      end
    end
  end
  
  class Configuration
    # The list of Objective-C frameworks that should be loaded.
    # (Defaults to <tt>Cocoa<tt/>)
    attr_reader :frameworks
    
    # An array of additional paths to prepend to the load path. By default,
    # all +app+, +lib+, and +vendor+ paths are included in this list.
    attr_reader :load_paths
    
    # An array of libraries to be required, _after_ the environment and plugins
    # have been loaded and the load path has been set, but _before_ any of the
    # applications's files are loaded.
    attr_reader :require_queue
    
    def initialize
      @frameworks    = default_frameworks
      @load_paths    = default_load_paths
      @require_queue = default_require_queue
    end
    
    # Adds a framework to the frameworks that are to be loaded.
    #
    # See frameworks for more info.
    def framework(framework)
      @frameworks << framework
    end
    
    # Adds a load path.
    #
    # See load_paths for more info.
    def load_path(path)
      @load_paths << path
    end
    
    # Adds a library to the require queue.
    #
    # See require_queue for more info.
    def require(library)
      @require_queue << library
    end
    
    private
    
    def default_require_queue
      []
    end
    
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