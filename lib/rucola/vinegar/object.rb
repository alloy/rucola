require 'rucola/vinegar/core_ext/nsobject'

module Rucola
  module Vinegar
    class Object
      class << self
        attr_reader :proxy_class
        
        def proxy_for(klass)
          @proxy_class = klass
          Rucola::Vinegar::PROXY_MAPPINGS[klass] = self
        end
      end
      
      def initialize(options = {})
        options.each do |key, value|
          send("#{key}=", value)
        end
      end
      
      def object
        unless @object
          @object = self.class.proxy_class.alloc.init
          @object.instance_variable_set(:@_vinegar_object, self)
        end
        @object
      end
    end
  end
end