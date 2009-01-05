module Test
  module Spec
    class TestCase
      class << self
        alias :dup :clone
      end
    end
  end
end

require "test/spec"

module Kernel
  def context(name, superclass=Test::Unit::TestCase, klass=Test::Spec::TestCase, &block)     # :doc:
    (Test::Spec::CONTEXTS[name] ||= klass.new(name, nil, superclass)).add(&block)
  end

  def xcontext(name, superclass=Test::Unit::TestCase, &block)     # :doc:
    context(name, superclass, Test::Spec::DisabledTestCase, &block)
  end

  def shared_context(name, &block)
    Test::Spec::SHARED_CONTEXTS[name] << block
  end

  alias :describe :context
  alias :xdescribe :xcontext
  alias :describe_shared :shared_context
end

# TODO: Find out why this is needed. Does this problem occur in 1.9 as well?
module Test::Spec::TestCase::InstanceMethods
  def call_methods_including_parents(method, reverse=false, klass=self.class)
    return unless klass
    
    if reverse
      if methods = klass.send(method)
        methods.each { |s| instance_eval(&s) }
      end
      call_methods_including_parents(method, reverse, klass.parent)
    else
      call_methods_including_parents(method, reverse, klass.parent)
      if methods = klass.send(method)
        methods.each { |s| instance_eval(&s) }
      end
    end
  end
end

module Kernel
  def unless_on_macruby
    yield if not defined?(MACRUBY_VERSION) || ENV['RUN_ALL_TESTS']
  end
end