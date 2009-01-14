# Don't change this file!
# Configure your app in config/environment.rb and config/environments/*.rb

require 'pathname'

module Rucola
  class << self
    def set_environment!
      Object.const_set("RUCOLA_ENV", discover_environment) unless defined?(RUCOLA_ENV)
    end
    
    def set_root!
      Object.const_set("RUCOLA_ROOT", Pathname.new(discover_root)) unless defined?(RUCOLA_ROOT)
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
      (RUCOLA_ROOT + 'vendor/rucola').exist?
    end
    
    private
    
    def discover_environment
      if env = ENV['RUCOLA_ENV']
        env
      elsif env = ENV['DYLD_LIBRARY_PATH']
        env = File.basename(env).downcase
        %{ debug release test }.include?(env) ? env : 'debug'
      elsif defined?(Rake)
        # presumably runnig from Rake
        'debug'
      else
        'release'
      end
    end
    
    def discover_root
      if env = ENV['RUCOLA_ROOT']
        env
      elsif RUCOLA_ENV == 'release'
        NSBundle.mainBundle.resourcePath.fileSystemRepresentation
      elsif RUCOLA_ENV == 'test' || (RUCOLA_ENV == 'debug' && defined?(Rake))
        # either `test` or `debug` and presumably runnig from Rake
        File.expand_path('../../', __FILE__)
      else
        File.expand_path('../../', ENV['DYLD_LIBRARY_PATH'])
      end
    end
  end
  
  class Boot
    def run
      load_initializer
      #Rucola::Initializer.run(:set_load_path)
      Rucola::Initializer.process
    end
  end
  
  class VendorBoot < Boot
    def load_initializer
      require RUCOLA_ROOT + "vendor/rucola/lib/initializer"
      #Rucola::Initializer.run(:install_gem_spec_stubs)
    end
  end
  
  class GemBoot < Boot
    def load_initializer
      require 'rubygems'
      require 'rucola/initializer'
    end
  end
  
  # All that for this:
  set_environment!
  set_root!
  boot! unless ENV['DONT_START_RUCOLA_APP']
end
