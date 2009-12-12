require 'rucola/vinegar/object'

module Rucola
  module Vinegar
    class View < Object
      def frame
        view.frame.to_a
      end
      
      def frame=(dimensions)
        view.frame = dimensions
      end
      
      def x;      frame[0]; end
      def y;      frame[1]; end
      def width;  frame[2]; end
      def height; frame[3]; end
      
      def views
        view.subviews.map(&:to_vinegar)
      end
      alias_method :to_a, :views
      
      def <<(subview)
        view.addSubview(subview.object)
      end
      alias_method :push, :<<
      
      private
      
      def view
        object
      end
    end
  end
end