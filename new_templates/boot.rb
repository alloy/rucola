# Don't change this file!
# Configure your app in config/environment.rb and config/environments/*.rb

unless defined?(RUCOLA_ROOT)
  require 'pathname'
  RUCOLA_ROOT = Pathname.new(File.expand_path('../..', __FILE__))
end

module Rucola
  class << self
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
      #Rails::Initializer.run(:install_gem_spec_stubs)
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
Rucola.boot!
