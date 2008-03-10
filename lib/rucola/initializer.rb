require 'osx/cocoa'
require 'pathname'

if !defined?(RUBYCOCOA_ENV) or RUBYCOCOA_ENV.nil?
  if ENV['RUBYCOCOA_ENV']
    RUBYCOCOA_ENV = ENV['RUBYCOCOA_ENV']
  else
    if ENV['DYLD_LIBRARY_PATH']
      env = ENV['DYLD_LIBRARY_PATH'].split('/').last.downcase
      if %(debug release test).include?(env)
        RUBYCOCOA_ENV = env
      else
        RUBYCOCOA_ENV = 'debug'
      end
    else
      RUBYCOCOA_ENV = 'release'
    end
  end
end

if !defined?(RUBYCOCOA_ROOT) or RUBYCOCOA_ROOT.nil?
  if ENV['RUBYCOCOA_ROOT']
    # rake will set the RUBYCOCOA_ROOT for debugging purpose
    RUBYCOCOA_ROOT = Pathname.new(ENV['RUBYCOCOA_ROOT'])
  else
    # We are running in debug from xcode, which doesn't set RUBYCOCOA_ROOT.
    # Or we are simply running in release.
    RUBYCOCOA_ROOT = 
      if RUBYCOCOA_ENV == 'release'
        Pathname.new(OSX::NSBundle.mainBundle.resourcePath.fileSystemRepresentation)
      else
        Pathname.new(ENV['DYLD_LIBRARY_PATH'] + "../../../").cleanpath
      end
  end
end

$:.unshift(RUBYCOCOA_ROOT.to_s)

module Rucola
  # Are we building and running or just running this application by clicking on 
  # an executable.
  def building_application?
    ENV['DYLD_LIBRARY_PATH']
  end
end


# we need to require everything that would be needed by a standalone application
require 'erb' # FIXME: this should only be required if we're really gonna use erb (AR project)
require 'rucola/rucola_support'
require 'rucola/dependencies'
require 'rucola/dependencies/exclusions'
require 'rucola/dependencies/override_require_and_gem'
require 'rucola/plugin'
require 'rucola/ruby_debug'

module Rucola
  # Rails-like Initializer responsible for processing configuration.
  class Initializer
    class << self
      def instance
        @initializer ||= new
      end
      
      # Load the config/boot.rb file.
      def boot
        Rucola::Plugin.before_boot
        do_boot
        Rucola::Plugin.after_boot
      end
      
      # Override this method from your Plugin.before_boot method if you need
      # to alter behaviour before any of the application's files are required
      # and the app is started.
      def do_boot
        Kernel.require Rucola::RCApp.root_path + '/config/boot'
      end
      
      # Returns the path to the plugins root directory. Eg /MyApp/vendor/plugins.
      def plugins_root
        RUBYCOCOA_ROOT + 'vendor/plugins'
      end
      
      # Loads all the plugins that are found in +plugins_root+.
      def load_plugins
        root = plugins_root
        if root.exist?
          root.children.each do |plugin|
            init_rb = plugin + 'init.rb'
            next unless init_rb.exist?
            Kernel.require init_rb
          end
        end
      end
      
      # Run the initializer and start the application.
      # Pass it a block to set the configuration.
      #
      #   Rucola::Initializer.run do |config|
      #     config.use_debugger = true
      #     # See +Configuration+ for more info on the options.
      #   end
      def run
        if @initializer.nil?
          @initializer = new
          
          yield @initializer.configuration if block_given?
          @initializer.process
          
          start_app
        else
          yield @initializer.configuration if block_given?
        end
      end
      
      # Starts the application's run loop.
      def start_app
        OSX.NSApplicationMain(0, nil) unless Rucola::RCApp.test? || ENV['DONT_START_RUBYCOCOA_APP']
      end
    end
    
    # The Configuration instance used by this Initializer instance.
    attr_reader :configuration
    
    # Create an initializer instance.
    def initialize
      @configuration = Configuration.new
    end
    
    # Step through the initialization routines.
    def process
      Rucola::Plugin.before_process(self)
      
      # load the environment config
      @configuration.load_environment_configuration!
      
      Rucola::Debugger.use! if @configuration.use_debugger
      use_reloader! if @configuration.use_reloader
      
      require_dependencies
      require_frameworks
      require_lib_source_files
      require_ruby_source_files
      
      Rucola::Plugin.after_process(self)
    end
    
    # Requires all the dependencies specified in config/dependencies.rb
    def require_dependencies
      deps_file = (RUBYCOCOA_ROOT + 'config/dependencies.rb').to_s
      Rucola::Dependencies.load(deps_file).require!
    end
    
    # Requires all frameworks specified by the Configuration#objc_frameworks
    # list.  This is also responsible for including osx/active_record_proxy if 
    # use_active_record? is true
    def require_frameworks
      configuration.objc_frameworks.each { |framework| OSX.require_framework(framework) }
    end
    
    # Recursively requires any ruby source file that it finds.
    def require_ruby_source_files_in_dir_recursive(dir)
      dir.children.each do |child|
        if child.directory?
          require_ruby_source_files_in_dir_recursive(child)
          next
        end
        require child if child.basename.to_s =~ /\.rb$/
      end
    end
    
    # Requires any ruby source files in the app/lib/ directory.
    def require_lib_source_files
      Dir[RUBYCOCOA_ROOT + 'lib/*.rb'].each do |f|
        require f
      end
    end
    
    # Loops through the subdirectories of the app/ directory.
    # It requires any ruby file in any of the subdirectories and registers
    # the required file in the hash +@require_ruby_source_files+ with the name
    # of the subdirectory as it's key.
    #
    # require_ruby_source_files # => {:models=>[], :views=>[], :controllers=>[#<Pathname:/src/SampleApp/app/controllers/ApplicationController.rb>]}
    def require_ruby_source_files
      Dir[RUBYCOCOA_ROOT + 'app/**/*.rb'].each do |f|
        require f
      end
    end
    
    # Loads the +Reloader+ lib if +use_reloader+ is set to +true+ on the +Configuration+.
    def use_reloader!
      if configuration.use_reloader
        Kernel.require 'rucola/reloader'
        Rucola::Reloader.start!
      end
    end
    
    def load_application_initializers
      Dir["#{configuration.root_path}/config/initializers/**/*.rb"].sort.each do |initializer|
        load(initializer)
      end
    end
    
    # Set the paths from which your application will automatically load source files.
    def set_load_path!
      load_paths = configuration.load_paths || [] # TODO: from script/console the configuration isn't ran.
      load_paths.reverse_each { |dir| $LOAD_PATH.unshift(dir) if File.directory?(dir) } unless Rucola::RCApp.test? # FIXME: why??
      $LOAD_PATH.uniq!
    end
  end
  
  class Configuration
    # The applications base directory
    attr_reader :root_path
    
    # The path to the applications support directory
    # <tt>~/Library/Application Support/AppName</tt>
    attr_accessor :application_support_path
    
    # List of Objective-C frameworks that should be required
    attr_accessor :objc_frameworks
    
    # An array of additional paths to prepend to the load path. By default,
    # all +models+, +config+, +controllers+ and +db+ paths are included in this list.
    attr_accessor :load_paths
    
    # Defines wether or not you want to use the +Reloader+.
    #
    # Turning on the reloader will start a fsevent loop which watches the files in app/ for changes
    # and try to reload any classes that have been saved while the app is running.
    #
    # It could however lead to erratic behaviour so use it with caution.
    attr_accessor :use_reloader
    
    # Defines wether or not you want to use the +debugger+.
    #
    # The debugger allows you to easily set breakpoints and debug them.
    # See the documentation from ruby-debug for its usage:
    # http://www.datanoise.com/ruby-debug/
    attr_accessor :use_debugger
    
    # Defines wether or not you want to allow the use of RubyGems.
    #
    # You can completely disable the usage of RubyGems by setting this to false.
    #
    # Unless you're using gems which are installed on a system by default, it's
    # better to set it to false. This will enable you to debug wether or not your
    # application has been bundled succesfully, PLUS not using rubygems will improve
    # the performance of your application.
    attr_accessor :use_rubygems
    
    # Declare which dependency types should be bundled with a release build.
    # Most of the times you would probably only bundle gems if you're targeting
    # a ruby which is compatible and contains the right site libs.
    #
    #   # Only bundles gems
    #   config.dependency_types = :gem
    #
    #   # Bundles gems and site libs
    #   config.dependency_types = :gem, :site
    #
    #   # Bundles site and other libs, where other are libs outside any of the default load paths.
    #   config.dependency_types = :site, :other
    attr_accessor :dependency_types
    
    def initialize
      @objc_frameworks  = []
      @load_paths       = default_load_paths
      @dependency_types = []
      @use_reloader = @use_debugger = @use_debugger = false
    end
    
    # Loads the current environment's file (debug.rb, release.rb, test.rb).
    # By default the file is at <tt>config/environments/#{environment}.rb</tt>.
    def load_environment_configuration!
      root = defined?(SOURCE_ROOT) ? SOURCE_ROOT : RCApp.root_path
      require "#{root}/config/environments/#{RCApp.env}.rb"
    end
    
    private
      # Set the load paths, which specifies what directories should be copied over on release.
      # We can't use RUBYCOCOA_ROOT here because when building for release the .app file is the 
      # root, instead we need the path to the working directory.
      def default_load_paths
        return if ENV['DYLD_LIBRARY_PATH'].nil?
        paths = %w(
          models
          controllers
          db
        ).map {|dir| "#{Pathname.new(ENV['DYLD_LIBRARY_PATH'] + "../../../").cleanpath}/#{dir}" }.select { |dir| File.directory?(dir) }
      end
  end
end

# Directly load plugins, so the Rucola Initializer & Configuration classes can be overriden.
Rucola::Initializer.load_plugins