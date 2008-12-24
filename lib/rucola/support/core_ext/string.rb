# String#snake_case & #camel_case:
# Copyright (c) 2008 Sam Smoot. Released under the MIT license.
# See: http://github.com/sam/extlib

module Rucola
  module CoreExt
    module String
      # Convert to snake case.
      #
      #   "FooBar".snake_case           #=> "foo_bar"
      #   "HeadlineCNNNews".snake_case  #=> "headline_cnn_news"
      #   "CNN".snake_case              #=> "cnn"
      def snake_case
        return self.downcase if self =~ /^[A-Z]+$/
        self.gsub(/([A-Z]+)(?=[A-Z][a-z]?)|\B[A-Z]/, '_\&') =~ /_*(.*)/
          return $+.downcase
      end
      
      # Convert to camel case.
      #
      #   "foo_bar".camel_case          #=> "FooBar"
      def camel_case
        return self if self !~ /_/ && self =~ /[A-Z]+.*/
        split('_').map{|e| e.capitalize}.join
      end
      
      # Returns the constant that this string refers to.
      #
      #  "FooBar".to_const # => FooBar
      #  "foo_bar".to_const # => FooBar
      def to_const
        Object.const_get(camel_case)
      end
    end
  end
end

String.send :include, Rucola::CoreExt::String