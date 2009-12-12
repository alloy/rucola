module Rucola
  module Vinegar
    class Object
      class << self
        attr_reader :proxy_class
        
        def proxy_for(klass)
          @proxy_class = klass
        end
      end
      
      def initialize(options = {})
        options.each do |key, value|
          send("#{key}=", value)
        end
      end
      
      def object
        @object ||= self.class.proxy_class.alloc.init
      end
    end
  end
end