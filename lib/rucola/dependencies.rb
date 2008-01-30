require 'rbconfig'

module Rucola
  class Dependencies
    class RequiredFile
      attr_reader :relative_path, :full_path
      
      def initialize(relative_path)
        resolve_relative_and_full_path(relative_path)
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
        dest_path = File.join(dest_dir, File.basename(@relative_path))
        return if File.exist?(dest_path)
        
        FileUtils.mkdir_p(dest_dir) unless File.exist?(dest_dir)
        
        puts "Copying '#{@full_path}' to '#{dest_path}'" if Dependencies.verbose
        FileUtils.cp(@full_path, dest_dir)
      end
      
      private
      
      # If the `relative_path` doesn't start with a slash then we only need to find the `full_path`,
      # otherwise we also need to get the `relative_path`.
      def resolve_relative_and_full_path(relative_path)
        @relative_path, @full_path = (relative_path =~ /^\// ? find_relative_and_full_path(relative_path) : [relative_path, find_full_path(relative_path)])
      end
      
      def find_full_path(relative_path)
        $LOAD_PATH.each do |load_path|
          full_path = File.join(load_path, relative_path)
          return full_path if File.exist?(full_path)
        end
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
      attr_reader :name, :version, :required_files
      
      def initialize(name, version = '>=0')
        @name, @version, @required_files = name, version, []
      end
      
      def require!
        puts "Activating dependency: #{@name} #{@version unless @version == '>=0'}" if Dependencies.verbose
        begin
          Gem.activate(@name, true, @version)
        rescue Gem::LoadError
        end
        Kernel.require(@name)
      end
      
      def resolve!
        require 'rubygems' rescue LoadError
        
        files = difference_in_loaded_features
        files.each { |file| @required_files << RequiredFile.new(file) }
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
      
      def copy_to(path)
        @required_files.each {|file| file.copy_to(path) }
      end
      
      private
      
      def difference_in_loaded_features
        loaded_features_before = $LOADED_FEATURES.dup
        $LOADED_FEATURES.replace([])
        require!
        result = $LOADED_FEATURES.dup
        $LOADED_FEATURES.replace(loaded_features_before)
        result
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
    
    def copy_to(path, options = {})
      if options[:types]
        @dependencies.each do |dep|
          if options[:types].any? {|type| dep.send "#{type}_lib?" }
            dep.copy_to(path)
          end
        end
      else
        @dependencies.each {|dep| dep.copy_to(path) }
      end
    end
    
    # Returns a string with a formatted representation of all the dependencies and their require files.
    def list
      resolve!
      str = ''
      @dependencies.each do |dep|
        str += "\nDependency '#{dep.name} (#{dep.version})' requires the following files:\n\n"
        dep.required_files.sort_by {|f| f.full_path }.each { |file| str += "  #{file.full_path}\n" }
      end
      str
    end
    
  end
end