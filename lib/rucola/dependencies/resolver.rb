require 'yaml'
require 'osx/cocoa'

require File.expand_path('../exclusions', __FILE__)

class DependencyResolver #:nodoc:
  class UnableToResolveError < StandardError #:nodoc:
  end

  def initialize(name, version)
    @name, @version = name, version
  end

  def require!
    verbose_before = $VERBOSE
    $VERBOSE = nil
    begin
      if Kernel.private_methods.include? 'gem_original_require'
        gem_original_require(@name)
      else
        require(@name)
      end
    rescue LoadError
      # unfortunately, rubygems will always require 'etc.bundle' & 'fileutils' so there's no real way of knowing
      # wether or not it was required by rubygems or the actual library.
      begin
        Gem.activate(@name, true, @version)
        require(@name)
      rescue NameError
        raise UnableToResolveError, "Unable to resolve: '#{@name}', '#{@version}'"
      end
    end
    $VERBOSE = verbose_before
  end

  def difference_in_loaded_features
    # save this to set it back to what it originally was
    loaded_features_before_rubygems = $LOADED_FEATURES.dup
    
    $LOADED_FEATURES.replace([])
    require 'rubygems' rescue LoadError
    
    Kernel.module_eval do
      alias_method :__require_before_dependency_resolver, :require
      def require(name)
        unless Rucola::Dependencies.exclude?(name)
          __require_before_dependency_resolver(name)
        end
      end
    end
    
    # save this so we can compare what else was added except for rubygems
    loaded_features_before = $LOADED_FEATURES.dup
    
    require!
    
    result = ($LOADED_FEATURES - loaded_features_before)
    $LOADED_FEATURES.replace(loaded_features_before_rubygems)
    result
  end
end

name, version = ARGV[0..1]
$LOAD_PATH.replace(YAML.load(ARGV[2])) unless ARGV[2].nil?

dr = DependencyResolver.new(name, version)
# print to stdout the serialized results array
puts YAML.dump(dr.difference_in_loaded_features)