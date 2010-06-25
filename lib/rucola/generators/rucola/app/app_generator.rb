require 'rucola/generators/base'

module Rucola
  module Generators
    module App
      class Type < Thor::Group
        argument :project_type, :type => :string
        
        def invoke_app_generator
          type = ARGV.shift
          generator_name = "#{project_type.camelize}Generator"
          Rucola::Generators::App.const_get(generator_name).start
        rescue NameError
          puts "No project generator of type `#{type}' exists."
          puts self.class.desc
          exit 1
        end
        
        def self.banner
          "rucola new #{arguments.map(&:usage).join(' ')}"
        end
        
        def self.desc
          "PROJECT_TYPE can be one of: #{Base.generators.join(', ')}"
        end
      end
      
      class Base < Rucola::Generators::Base
        argument :app_path, :type => :string
        
        attr_accessor :app_name
        
        # Keep a list of generators to display to the user in the Type banner
        def self.inherited(generator)
          (@generators ||= []) << generator.generator_name
        end
        def self.generators; @generators; end
        
        def self.source_root
          '/Library/Application Support/Developer/Shared/Xcode/Project Templates/Application'
        end
        
        def self.xcodeproj_template
          Dir.glob(File.join(source_root, '*.xcodeproj')).first
        end
        
        def self.xcodeproj_template_info
          path = File.join(xcodeproj_template, 'TemplateInfo.plist')
          NSDictionary.dictionaryWithContentsOfFile(path)
        end
        
        def self.banner
          "rucola new #{generator_name} #{arguments.map(&:usage).join(' ')} [options]"
        end
        
        def self.desc
          xcodeproj_template_info['Description']
        end
        
        def initialize(*args)
          super
          self.app_name = File.basename(app_path).camelize
          self.destination_root = File.expand_path(app_path, destination_root)
        end
        
        def create_root
          empty_directory '.'
        end
        
        def create_xcodeproj
          xcodeproj = "#{app_name}.xcodeproj"
          empty_directory xcodeproj
          template "MacRubyApp.xcodeproj/project.pbxproj", File.join(xcodeproj, "project.pbxproj")
        end
      end
      
      class AppGenerator < Base
        def self.source_root
          @source_root ||= File.join(super, 'MacRuby Application')
        end
      end
      
      class CoreDataAppGenerator < Base
        def self.source_root
          @source_root ||= File.join(super, 'MacRuby Core Data Application')
        end
      end
      
      class DocumentAppGenerator < Base
        def self.source_root
          @source_root ||= File.join(super, 'MacRuby Document-based Application')
        end
      end
      
      class PrefPaneGenerator < Base
        def self.source_root
          @source_root ||= File.join(super, 'MacRuby Preference Pane')
        end
      end
    end
  end
end