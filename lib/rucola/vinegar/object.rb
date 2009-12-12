require 'rucola/vinegar/core_ext'

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
        @object = options.delete(:object)
        options.each do |key, value|
          send("#{key}=", value)
        end
      end
      
      def object
        unless @object
          init_object
          @object.instance_variable_set(:@_vinegar_object, self)
        end
        @object
      end
      
      protected
      
      def init_object
        @object = self.class.proxy_class.alloc.init
      end
    end
  end
end