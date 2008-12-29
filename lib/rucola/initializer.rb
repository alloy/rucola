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
    end
  end
  
  class Configuration
  end
end