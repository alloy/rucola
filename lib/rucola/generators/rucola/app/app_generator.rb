require 'rucola/generators/base'

module Rucola
  module Generators
    class AppBase < Base
      argument :app_path, :type => :string
      
      def self.source_root
        '/Library/Application Support/Developer/Shared/Xcode/Project Templates/Application'
      end
      
      def create_root
        self.destination_root = File.expand_path(app_path, destination_root)
        empty_directory '.'
      end
    end
    
    class AppGenerator < AppBase
      def self.source_root
        @source_root ||= File.join(super, 'MacRuby Application')
      end
    end
    
    class CoreDataAppGenerator < AppBase
      def self.source_root
        @source_root ||= File.join(super, 'MacRuby Core Data Application')
      end
    end
    
    class DocumentAppGenerator < AppBase
      def self.source_root
        @source_root ||= File.join(super, 'MacRuby Document-based Application')
      end
    end
    
    class PrefPaneGenerator < AppBase
      def self.source_root
        @source_root ||= File.join(super, 'MacRuby Preference Pane')
      end
    end
  end
end