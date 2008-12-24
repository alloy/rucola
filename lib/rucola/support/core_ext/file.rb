module Rucola
  module CoreExt
    module File
      # Returns the constant version of the file that is referred to.
      #
      #   File.to_const("/some/path/foo_bar_controller.rb") # => FooBarController
      def to_const(file)
        file.match /(\w+)\.\w*$/
        $1.to_const
      end
    end
  end
end

File.send :extend, Rucola::CoreExt::File