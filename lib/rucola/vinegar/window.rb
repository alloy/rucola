require 'rucola/vinegar/view'

module Rucola
  module Vinegar
    class Window < Object
      def frame
        object.contentView.frame
      end
      
      def frame=(dimensions)
        object.contentView.setFrame(dimensions, display: true)
      end
      
      def width;  frame.size.width ; end
      def height; frame.size.height; end
      def x;      frame.origin.x;    end
      def y;      frame.origin.y;    end
      
      def views
        object.contentView.subviews
      end
      alias_method :to_a, :views
      
      def visible?
        object.visible?
      end
      
      def show
        object.display
        object.orderFrontRegardless
      end
      
      def <<(view)
        object.contentView.addSubview(view.object)
      end
      alias_method :push, :<<
      
      protected
      
      def init_object
        @object = NSWindow.alloc.initWithContentRect([100, 100, 480, 270],
                                  styleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask,
                                  backing:   NSBackingStoreBuffered,
                                  defer:     false)
      end
    end
  end
end