require 'rbconfig'
require 'yaml'

require 'dependencies/exclusions'

module Rucola
  class Dependencies
    class RequiredFile
      class UnableToResolveFullPathError < StandardError; end
      
      attr_reader :relative_path, :full_path
      
      def initialize(relative_path)
        @relative_path, @full_path = resolve_relative_and_full_path(relative_path)
      end
      
      def gem_lib?
        Gem.path.any? {|load_path| @full_path =~ /^#{load_path}/ }
      end
      
      def standard_lib?
        @full_path =~ /^#{Config::CONFIG['rubylibdir']}/
      end
      
      def other_lib?
        !gem_lib? && !standard_lib?
      end
      
      def copy_to(path)
        dest_dir = File.join(path, File.dirname(@relative_path))
        dest_path = File.expand_path(File.join(dest_dir, File.basename(@relative_path)))
        return if File.exist?(dest_path)
        
        FileUtils.mkdir_p(dest_dir) unless File.exist?(dest_dir)
        
        puts "  #{@full_path}" if Dependencies.verbose
        FileUtils.cp(@full_path, dest_dir)
      end
      
      def ==(other)
        @full_path == other.full_path
      end
      
      private
      
      # If the `relative_path` doesn't start with a slash then we only need to find the `full_path`,
      # otherwise we also need to get the `relative_path`.
      def resolve_relative_and_full_path(relative_path)
        relative_path =~ /^\// ? find_relative_and_full_path(relative_path) : [relative_path, find_full_path(relative_path)]
      end
      
      def find_full_path(relative_path)
        $LOAD_PATH.each do |load_path|
          full_path = File.join(load_path, relative_path)
          return full_path if File.exist?(full_path)
        end
        raise UnableToResolveFullPathError, "Unable to resolve the full path for: #{relative_path}"
      end
      
      def find_relative_and_full_path(relative_path)
        $LOAD_PATH.each do |load_path|
          if relative_path =~ /^#{load_path}/
            res_full_path = relative_path
            res_relative_path = relative_path[load_path.length..-1]
            puts "WARNING: Not a relative path '#{relative_path}', assuming '#{res_relative_path}'" if Dependencies.verbose
            return [res_relative_path, res_full_path]
          end
        end
      end
    end
    
    class Dependency
      attr_reader :name, :version
      
      def initialize(name, version = '>=0')
        @name, @version, @required_files = name, version, []
      end
      
      def require!
        begin
          Gem.activate(@name, true, @version)
        rescue Gem::LoadError
        end
        Kernel.require(@name)
      end
      
      RUBY_BIN = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])
      RESOLVER_BIN = File.expand_path("../dependencies/resolver.rb", __FILE__)
      def resolve!
        unless Dependencies.exclude?(@name)
          without_changing_loaded_features do
            cmd = "'#{RUBY_BIN}' '#{RESOLVER_BIN}' '#{@name}' '#{@version}' '#{YAML.dump($LOAD_PATH)}'"
            files = YAML.load(`#{cmd}`)
            require!
            files.each { |file| @required_files << RequiredFile.new(file) }
          end
        end
      end
      
      def gem_lib?
        @required_files.first.gem_lib?
      end
      
      def standard_lib?
        @required_files.first.standard_lib?
      end
      
      def other_lib?
        @required_files.first.other_lib?
      end
      
      def copy_to(path, options = {})
        puts "\nCopying dependency '#{pretty_print_name}':\n\n" if Dependencies.verbose
        required_files_of_types(options[:types]).each {|file| file.copy_to(path) }
      end
      
      # Returns an array of required files sorted by their full_path.
      def required_files
        @required_files.sort_by {|f| f.full_path }
      end
      
      def required_files_of_types(*types)
        sorted_types = types.flatten.compact
        return required_files if sorted_types.empty?
        required_files.select do |file|
          sorted_types.any? {|type| file.send "#{type}_lib?" }
        end
      end
      
      def pretty_print_name
        "#{@name}#{' (' + @version + ')' unless @version == '>=0'}"
      end
      
      private
      
      def without_changing_loaded_features
        loaded_features_before = $LOADED_FEATURES.dup
        yield
        $LOADED_FEATURES.replace(loaded_features_before)
      end
    end
  end
  
  class Dependencies
    class << self
      @@verbose = true
      def verbose
        @@verbose
      end
      def verbose=(value)
        if value
          $VERBOSE = true
        else
          $VERBOSE = nil
        end
        @@verbose = value
      end
      
      # Loads dependencies from a file which uses 'Rucola::Dependencies.run do ... end' to define dependencies.
      def load(dependencies_file)
        require dependencies_file
        instance
      end
      
      def run(&block)
        instance.instance_eval(&block)
      end
      
      def instance
        @instance ||= new
      end
    end
    
    attr_reader :dependencies
    
    def initialize
      @dependencies = []
    end
    
    def dependency(name, version = '>=0')
      @dependencies << Dependency.new(name, version)
    end
    
    def require!
      @dependencies.each {|dep| dep.require! }
    end
    
    def resolve!
      @dependencies.each {|dep| dep.resolve! }
    end
    
    # Requires an array of all the required files with any duplicates removed.
    # TODO: Check if using this will save a lot of time while copying,
    # because atm files might be copied multiple times.
    def required_files(*types)
      files = @dependencies.collect {|dep| dep.required_files_of_types(types) }.flatten
      unique_files = []
      files.each { |file| unique_files << file unless unique_files.include?(file) }
      unique_files
    end
    
    def copy_to(path, options = {})
      @dependencies.each {|dep| dep.copy_to(path, options) }
    end
  end
end