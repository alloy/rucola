module Rucola
  module Vinegar
    class Button
      attr_reader :object
      attr_accessor :action
      
      def initialize(x = 14, y = 14, width = 96, height = 32, &block)
        @object = NSButton.alloc.initWithFrame([x, y, width, height])
        @object.target, @object.action = self, :click
        
        @action = block
      end
      
      def frame
        @object.frame
      end
      
      def width;  frame.size.width ; end
      def height; frame.size.height; end
      def x;      frame.origin.x;    end
      def y;      frame.origin.y;    end
      
      def click(sender = nil)
        @action.call(self)
      end
    end
  end
end