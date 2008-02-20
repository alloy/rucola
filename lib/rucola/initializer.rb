require 'osx/cocoa'
require 'pathname'

require 'rucola/rucola_support/rc_app'
require 'rucola/plugin'

unless ENV['RUBYCOCOA_ENV'].nil?
  RUBYCOCOA_ENV = ENV['RUBYCOCOA_ENV']
else
  unless ENV['DYLD_LIBRARY_PATH'].nil?
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

# The env has been set, so we can load the debugger lib.
require 'rucola/ruby_debug'

unless ENV['RUBYCOCOA_ROOT'].nil?
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

$:.unshift(RUBYCOCOA_ROOT)

module Rucola
  # Are we building and running or just running this application by clicking on 
  # an executable.
  def building_application?
    ENV['DYLD_LIBRARY_PATH']
  end
end


# Environment initialization scheme ported/derived from Rails' Initializer.
require 'erb' # FIXME: this should only be required if we're really gonna use erb (AR project)
module Rucola
  # Rails-like Initializer responsible for processing configuration.
  class Initializer
    # The Configuration instance used by this Initializer instance.
    attr_reader :configuration
    
    class << self
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
        require RUBYCOCOA_ROOT + 'config/boot'
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
      
      # Run the initializer and start the application.  The #process method is run by default which 
      # runs all the initialization routines.  You can alternatively specify 
      # a command to run.
      # 
      #    OSX::Initializer.run(:set_load_path)
      #
      def run(command = :process, configuration = Configuration.new)
        yield configuration if block_given?
        initializer = new configuration
        initializer.send(command)
        start_app
      end
      
      # Starts the application's run loop.
      def start_app
        OSX.NSApplicationMain(0, nil) unless RUBYCOCOA_ENV == 'test' || ENV['DONT_START_RUBYCOCOA_APP']
      end
    end
    
    # Create an initializer instance that references the given 
    # Configuration instance. 
    def initialize(configuration)
      @configuration = configuration
    end
    
    # Step through the initialization routines, skipping the active_record 
    # routines if active_record isnt' being used.
    def process
      Rucola::Plugin.before_process(self)
      unless ENV['DYLD_LIBRARY_PATH'].nil?
        set_load_path
        copy_load_paths_for_release
      end
      
      require_rucola_support
      require_dependencies
      require_frameworks
      require_lib_source_files
      require_ruby_source_files
      require_reloader
      load_environment
      Rucola::Plugin.after_process(self)
    end
    
    # Requires all the dependencies specified in config/dependencies.rb
    def require_dependencies
      deps_file = (RUBYCOCOA_ROOT + 'config/dependencies.rb').to_s
      if File.exist?(deps_file)
        require 'rucola/dependencies'
        Rucola::Dependencies.load(deps_file).require!
      else
        puts "\nWARNING: You are encouraged to specify your application's dependencies in config/dependencies.rb\n\n"
      end
    end
    
    # Requires all frameworks specified by the Configuration#objc_frameworks
    # list.  This is also responsible for including osx/active_record_proxy if 
    # use_active_record? is true
    def require_frameworks
      configuration.objc_frameworks.each { |framework| OSX.require_framework(framework) }
    end
    
    # Loads the Rucola support library
    def require_rucola_support
      require Pathname.new(__FILE__).dirname + 'rucola_support'
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
    def require_reloader
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
    
    # Loads the environment specified by Configuration#environment_path, which
    # can be debug or release
    def load_environment
      return if @environment_loaded
      @environment_loaded = true
      
      config = configuration
      constants = self.class.constants
      eval(IO.read(configuration.environment_path), binding, configuration.environment_path)

      (self.class.constants - constants).each do |const|
        Object.const_set(const, self.class.const_get(const))
      end
    end
    
    # Set the paths from which your application will automatically load source files.
    def set_load_path
      load_paths = configuration.load_paths || [] # TODO: from script/console the configuration isn't ran.
      load_paths.reverse_each { |dir| $LOAD_PATH.unshift(dir) if File.directory?(dir) } unless RUBYCOCOA_ENV == 'test' # FIXME: why??
      $LOAD_PATH.uniq!
    end
    
    # Copy the default load paths to the resource directory for the application if 
    # we are building a release, otherwise we do nothing. When in debug or test mode,
    # the files are loaded directly from your working directory.
    #
    # TODO: Remove debug database from released app if it exists.
    def copy_load_paths_for_release
      return unless configuration.environment == 'release'
      configuration.load_paths.each do |path|
        `cp -R #{path} #{RUBYCOCOA_ROOT}/#{File.basename(path)}` if File.directory?(path)
      end
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
    # In debug mode this defaults to +true+.
    attr_accessor :use_reloader
    
    def initialize
      set_root_path!
      set_application_support_path!
      
      self.objc_frameworks = []
      self.load_paths      = default_load_paths
      self.use_reloader    = (RUBYCOCOA_ENV == 'debug')
    end
    
    def set_root_path!
      @root_path = Pathname.new(::RUBYCOCOA_ROOT).realpath.to_s
    end
    
    def set_application_support_path!
      # TODO: we might want to set this to something in test mode.
      return if RUBYCOCOA_ENV == 'test'
      
      user_app_support_path = File.join(OSX::NSSearchPathForDirectoriesInDomains(OSX::NSLibraryDirectory, OSX::NSUserDomainMask, true)[0].to_s, "Application Support")
      @application_support_path = File.join(user_app_support_path, Rucola::RCApp.app_name)
    end
    
    # Returns the value of RUBYCOCOA_ENV
    def environment
      ::RUBYCOCOA_ENV
    end
    
    # The path to the current environment's file (development.rb, etc.). By
    # default the file is at <tt>config/environments/#{environment}.rb</tt>.
    def environment_path
      "#{root_path}/config/environments/#{environment}.rb"
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