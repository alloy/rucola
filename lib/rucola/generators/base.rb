require 'rucola'
require 'thor/group' # TODO gem

module Rucola
  module Generators
    # TODO for now a (almost) verbatim copy from railties/lib/rails/generators/base.rb
    class Base < Thor::Group
      include Thor::Actions
      
      add_runtime_options!
      
      def self.source_root
        @source_root ||= default_source_root
      end
      
      def self.default_source_root
        path = File.expand_path(File.join(base_name, generator_name, 'templates'), base_root)
        path if File.exist?(path)
      end
      
      def self.base_root
        File.dirname(__FILE__)
      end
      
      def self.base_name
        @base_name ||= begin
          if base = name.to_s.split('::').first
            base.underscore
          end
        end
      end
      
      def self.generator_name
        @generator_name ||= begin
          if generator = name.to_s.split('::').last
            generator.sub!(/Generator$/, '')
            generator.underscore
          end
        end
      end
    end
  end
end