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
      
      def load_environment
        require RCApp.root_path + "config/environment.rb"
        require RCApp.root_path + "config/environment/#{RCApp.env}.rb"
      end
    end
  end
  
  class Configuration
    # The list of Objective-C frameworks that should be loaded.
    # (Defaults to <tt>Cocoa<tt/>)
    attr_accessor :frameworks
    
    def initialize
      self.frameworks = default_frameworks
    end
    
    private
    
    def default_frameworks
      %w{ Cocoa }
    end
  end
end