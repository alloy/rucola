require 'osx/cocoa'

class Object
  # A mocha helper to get at an instance variable without having to use instance_variable_get.
  #
  #   obj.ivar(:some_ivar).expects(:foo)
  def ivar(name)
    instance_variable_get("@#{name}".to_sym)
  end
end

module OSX
  # Allows methods to be overriden with a different arity.
  #
  # TODO: Check with Laurent if this is bad?
  # Otherwise we should maybe override the stub method to set this to true
  # when the object is a subclass of OSX::NSObject and set it to false again after the stubbing.
  def self._ignore_ns_override; true; end

  class NSObject
    # A mocha helper to get at an outlet (ivar) without having to use instance_variable_get.
    #
    #   obj.ib_outlet(:some_text_view).expects(:string=).with('foo')
    alias_method :ib_outlet, :ivar
    
    # A Mocha helper method which allows to stub alloc.init and return a mock.
    #
    #   it "should init and return an instance" do
    #     obj_mock = mock("NSObject mock")
    #     OSX::NSObject.expects_alloc_init_returns(obj_mock) # performs 2 assertions
    #     OSX::NSObject.alloc.init.should == obj_mock
    #   end
    #
    # Results in:
    # 1 tests, 3 assertions, 0 failures, 0 errors
    def self.expects_alloc_init_returns(mock)
      mock.expects(:init).returns(mock)
      self.expects(:alloc).returns(mock)
    end
    
    # A Mocha helper method which allocs an instance, yields it and then calls init.
    #
    #   class Monkey < OSX::NSObject
    #     def init
    #       if super_init
    #         self.foo
    #         self.bar
    #         return self
    #       end
    #     end
    #   end
    #
    #   it "should alloc, yield and return an instance" do
    #     obj = OSX::Monkey.during_init do |instance|
    #       instance.expects(:foo)
    #       instance.expects(:bar)
    #     end
    #     p obj # => #<Monkey:0x1a7566 class='Monkey' id=0x1b30a70>
    #   end
    #
    # Results in:
    # 1 tests, 2 assertions, 0 failures, 0 errors
    def self.during_init(&block)
      obj = self.alloc
      yield obj
      res = obj.init
      warn " warning: #{self.class.name}#init did not return an instance." if res.nil?
      res
    end
  end
end