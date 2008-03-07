module Rucola
  class Dependencies
    class << self
      def exclusions
        @exclusions ||= []
      end
      
      def exclude(regexp)
        exclusions << regexp
      end
      
      def exclude?(name)
        exclusions.any? { |regexp| name =~ regexp }
      end
    end
    
    # define libs that should not be resolved here
    exclude(/osx\//)
  end
end