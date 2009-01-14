require 'rucola/rake'

module Rucola
  module Rake
    module TestHelper
      def executed_commands
        @executed_commands ||= {}
      end
      
      def execute_command(name, args)
        (executed_commands[name] ||= []) << args
      end
      
      def sh(*args)
        execute_command :sh, args
      end
      
      module Assertions
        def assert_executed(name, *args)
          assert_equal args, rake_lib_instance.executed_commands[name]
        end
        alias_method :should_have_executed, :assert_executed
      end
    end
  end
end

Rucola::Rake::Builder.send(:include, Rucola::Rake::TestHelper)