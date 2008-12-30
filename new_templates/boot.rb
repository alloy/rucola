# Don't change this file!
# Configure your app in config/environment.rb and config/environments/*.rb

unless defined?(RUCOLA_ROOT)
  require 'pathname'
  RUCOLA_ROOT = Pathname.new(File.expand_path('../..', __FILE__))
end

module Rucola
  class << self
    def set_environment!
      Object.const_set("RUCOLA_ENV", discover_environment) unless defined?(RUCOLA_ENV)
    end
    
    def set_root!
      Object.const_set("RUCOLA_ROOT", discover_root) unless defined?(RUCOLA_ROOT)
    end
    
    def boot!
      pick_boot.run unless booted?
    end
    
    def booted?
      defined? Rucola::Initializer
    end
    
    def pick_boot
      (vendor_rucola? ? VendorBoot : GemBoot).new
    end
    
    def vendor_rucola?
      File.exist?("#{RUCOLA_ROOT}/vendor/rucola")
    end
    
    private
    
    def discover_environment
      if env = ENV['RUCOLA_ENV']
        env
      else
        if ENV['DYLD_LIBRARY_PATH']
          env = ENV['DYLD_LIBRARY_PATH'].split('/').last.downcase
          if %(debug release test).include?(env)
            env
          else
            'debug'
          end
        else
          'release'
        end
      end
    end
    
    def discover_root
      if env = ENV['RUCOLA_ROOT']
        env
      else
        if RUCOLA_ENV == 'release'
          NSBundle.mainBundle.resourcePath.fileSystemRepresentation
        else
          File.expand_path('../../', ENV['DYLD_LIBRARY_PATH'])
        end
      end
    end
  end
  
  class Boot
    def run
      load_initializer
      Rucola::Initializer.run(:set_load_path)
    end
  end
  
  class VendorBoot < Boot
    def load_initializer
      require "#{RUCOLA_ROOT}/vendor/rucola/lib/initializer"
      #Rucola::Initializer.run(:install_gem_spec_stubs)
    end
  end
  
  class GemBoot < Boot
    def load_initializer
      require 'rubygems'
      require 'rucola/initializer'
    end
  end
end

# All that for this:
Rucola.boot! unless ENV['DONT_START_RUCOLA_APP']
