module Rucola
  module Vinegar
    class Window
      attr_reader :object
      
      def initialize(width = 600, height = 450, x = 100, y = 100)
        @object = NSWindow.alloc.initWithContentRect([x, y, width, height],
                                  styleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask,
                                  backing:   NSBackingStoreBuffered,
                                  defer:     false)
      end
      
      def frame
        @object.contentView.frame
      end
      
      def width;  frame.size.width ; end
      def height; frame.size.height; end
      def x;      frame.origin.x;    end
      def y;      frame.origin.y;    end
    end
  end
end