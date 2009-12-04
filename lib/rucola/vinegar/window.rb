module Rucola
  module Vinegar
    class Window
      attr_reader :object
      
      def initialize(x = 100, y = 100, width = 480, height = 270)
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
      
      def views
        @object.contentView.subviews
      end
      alias_method :to_a, :views
      
      def visible?
        @object.visible?
      end
      
      def show
        @object.display
        @object.orderFrontRegardless
      end
      
      def <<(view)
        @object.contentView.addSubview(view.object)
      end
      alias_method :push, :<<
    end
  end
end