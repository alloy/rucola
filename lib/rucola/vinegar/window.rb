require 'rucola/vinegar/view'

module Rucola
  module Vinegar
    class Window < View
      def frame=(dimensions)
        object.contentView.setFrame(dimensions, display: true)
      end
      
      def visible?
        object.visible?
      end
      
      def show
        object.display
        object.orderFrontRegardless
      end
      
      protected
      
      def init_object
        @object = NSWindow.alloc.initWithContentRect([100, 100, 480, 270],
                                  styleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask,
                                  backing:   NSBackingStoreBuffered,
                                  defer:     false)
      end
      
      private
      
      def view
        object.contentView
      end
    end
  end
end