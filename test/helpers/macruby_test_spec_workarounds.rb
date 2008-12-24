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