require 'rucola/vinegar/view'

module Rucola
  module Vinegar
    class Button < View
      proxy_for NSButton
      
      attr_accessor :action
      
      def initialize(options = {}, &block)
        super(options)
        @action = block
      end
      
      def click(sender = nil)
        @action.call(self)
      end
      
      protected
      
      def init_object
        super
        self.frame = [14, 14, 96, 32]
        @object.bezelStyle = NSRoundedBezelStyle
        @object.target, @object.action = self, :click
      end
    end
  end
end