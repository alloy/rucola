class File
  class << self
    # Returns the constant version of the file that is referred to.
    #
    #   File.constantize("/some/path/foo_bar_controller.rb") # => FooBarController
    def constantize(file)
      file.match /(\w+)\.\w*$/
      $1.constantize
    end
  end
end