class String
  # These 2 methods are taken blatently from the Merb string extensions.
  
  # "FooBar".snake_case #=> "foo_bar"
  def snake_case
    gsub(/\B[A-Z]/, '_\&').downcase
  end

  # "foo_bar".camel_case #=> "FooBar"
  def camel_case    
    if self.include? '_'
      self.split('_').map{|e| e.capitalize}.join
    else
      unless self =~ (/^[A-Z]/)
        self.capitalize
      else
        self
      end
    end
  end
end
