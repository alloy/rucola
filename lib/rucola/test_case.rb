class OSX::NSObject
  class << self
    # An array of defined ib_outlets.
    def defined_ib_outlets
      @defined_ib_outlets ||= []
    end
    
    # Override ib_outlets so we can store which ones need to be defined.
    def ib_outlets(*outlets)
      defined_ib_outlets.concat(outlets.flatten)
    end
    alias_method :ib_outlet, :ib_outlets
  end
end

module Rucola
  module TestCase
    # Defines the controller that will be tested.
    #
    #   class ApplicationController < OSX::NSObject
    #     ib_outlet :window
    #     ib_outlets :tableView, :searchField
    #     ib_outlets :textField
    #   end
    #
    #   class TestFoo < Test::Unit::TestCase
    #     tests ApplicationController
    #     
    #     def after_setup
    #       ib_outlets :window => mock("Main Window"),
    #                  :tableView => OSX::NSTableView.alloc.init,
    #                  :searchField => OSX::NSSearchField.alloc.init
    #       
    #       window.stubs(:title => 'Main Window')
    #       tableView.addTableColumn OSX::NSTableColumn.alloc.init
    #       searchField.stringValue = "foo"
    #     end
    #     
    #     def test_something
    #       p controller # => #<ApplicationController:0xdfa1ce class='ApplicationController' id=0x1e8d0e0>
    #       p window.title # => "Main Window"
    #       p tableView.tableColumns # => #<NSCFArray [#<OSX::NSTableColumn:0xdf9d0a class='NSTableColumn' id=0x1e90d00>]>
    #       p searchField # => #<OSX::NSSearchField:0xdfa43a class='NSSearchField' id=0x1e84cb0>
    #
    #       # Note that we haven't set the textField ib_outlet to anything else in the after_setup method,
    #       # so it will be a stub which responds to everything by returning nil.
    #       p textField # => #<Mock:textField>
    #     end
    #   end
    def tests(class_to_be_tested)
      @class_to_be_tested = class_to_be_tested
      include Rucola::TestCase::InstanceMethods
    end
    
    module InstanceMethods
      # Sets up the ib_outlets to all be stubs which respond to everything with nil.
      #
      # In your test use #after_setup to do any custom setup.
      def setup
        class_to_be_tested.defined_ib_outlets.each do |outlet|
          ib_outlet(outlet, stub_everything(outlet.to_s))
        end
        after_setup if respond_to? :after_setup
      end
      
      # Sets the ib_outlets and instance to be tested to nil at the end of the test.
      #
      # In your test use #after_teardown to do any custom teardown.
      def teardown
        class_to_be_tested.defined_ib_outlets.each do |outlet|
          instance_to_be_tested.instance_variable_set("@#{outlet}", nil)
        end
        @instance_to_be_tested = nil
        after_teardown if respond_to? :after_teardown
      end
      
      # Returns the class that's to be tested.
      def class_to_be_tested
        self.class.instance_variable_get(:@class_to_be_tested)
      end
      
      # An instance of the class that's to be tested.
      def instance_to_be_tested
        @instance_to_be_tested ||= class_to_be_tested.alloc.init
      end
      alias_method :controller, :instance_to_be_tested
      
      # Lets you get an instance variable from the instance.
      #
      #   obj.instance_variable_set(:@some_attr, 'foo')
      #   assigns(:some_attr) # => 'foo'
      #
      # You can also set an instance variable in the instance.
      #
      #   obj.assigns(:some_attr, 'bar')
      #   obj.instance_variable_get(:@some_attr) # => 'bar'
      def assigns(name, obj = nil)
        obj.nil? ? instance_to_be_tested.instance_variable_get("@#{name}") : instance_to_be_tested.instance_variable_set("@#{name}", obj)
      end
      
      # Defines instance variables in the instance which represent the ib_outlets.
      # It basically just sets the instance variables, but also creates shorcut accessors to get at them from your tests.
      #
      #   def after_setup
      #     ib_outlet :textField, OSX::NSTextField.alloc.init
      #     p textField # => #<OSX::NSTextField:0xdfa3f4 class='NSTextField' id=0x1e842b0>
      #   end
      #
      # Note that not every class can be instantiated in a test.
      # So you can also supply something like a mock.
      def ib_outlet(name, obj)
        unless respond_to? name
          self.class.class_eval do
            define_method(name) { assigns(name) }
            private name
          end
        end
        assigns(name, obj)
      end
      
      # Shortcut method to defined multiple ib_outlets by supplying a hash.
      #
      #   def after_setup
      #     ib_outlets :window => mock("Main Window"),
      #                :tableView => OSX::NSTableView.alloc.init,
      #                :searchField => OSX::NSSearchField.alloc.init
      #   end
      def ib_outlets(outlets)
        outlets.each {|k,v| ib_outlet(k, v) }
      end
    end
  end
end
Test::Unit::TestCase.send(:extend, Rucola::TestCase)