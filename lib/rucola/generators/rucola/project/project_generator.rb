require 'rucola/generators/base'
require 'rucola/generators/xcode_template'

module Rucola
  module Generators
    module Project
      class Type < Thor::Group
        argument :project_type, :type => :string
        
        def invoke_project_generator
          ARGV.shift # be sure to remove project_type from ARGV before starting generator
          
          generator_name = "#{project_type.camelize}Generator"
          if Rucola::Generators::Project.const_defined?(generator_name)
            Rucola::Generators::Project.const_get(generator_name).start
          else
            puts "No project generator of type `#{project_type}' exists."
            puts self.class.desc
            exit 1
          end
        end
        
        def self.banner
          "rucola new #{arguments.map(&:usage).join(' ')}"
        end
        
        def self.desc
          "PROJECT_TYPE can be one of: #{Base.generators.join(', ')}"
        end
      end
      
      class Base < Rucola::Generators::Base
        include XCodeTemplate::Actions
        
        argument :project_path, :type => :string
        
        attr_accessor :project_name
        
        # These aliases are for the xcode template
        # TODO: need to see if there are any problems with simply returning the
        # project_name as PROJECTNAMEASXML
        alias_method :PROJECTNAME, :project_name
        alias_method :PROJECTNAMEASXML, :project_name
        
        # Keep a list of generators to display to the user in the Type banner
        def self.inherited(generator)
          (@generators ||= []) << generator.generator_name
        end
        
        def self.generators
          @generators
        end
        
        def self.source_root
          '/Library/Application Support/Developer/Shared/Xcode/Project Templates'
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
          self.project_name = File.basename(project_path).camelize
          self.destination_root = File.expand_path(project_path, destination_root)
        end
        
        def create_root
          empty_directory '.'
        end
        
        def create_xcodeproj
          xcodeproj = "#{project_name}.xcodeproj"
          empty_directory xcodeproj
          xcode_template "MacRubyApp.xcodeproj/project.pbxproj", File.join(xcodeproj, "project.pbxproj")
        end
        
        def create_root_files
          Dir.chdir(self.class.source_root) do
            files = Dir.glob("*.*")
            files.reject! { |f| %w{ .lproj .xcodeproj }.include? File.extname(f) }
            files.each { |f| xcode_template f }
          end
        end
      end
      
      class AppGenerator < Base
        def self.source_root
          @source_root ||= File.join(super, 'Application/MacRuby Application')
        end
      end
      
      class CoreDataAppGenerator < Base
        def self.source_root
          @source_root ||= File.join(super, 'Application/MacRuby Core Data Application')
        end
      end
      
      class DocumentAppGenerator < Base
        def self.source_root
          @source_root ||= File.join(super, 'Application/MacRuby Document-based Application')
        end
      end
      
      class PrefPaneGenerator < Base
        def self.source_root
          @source_root ||= File.join(super, 'System Plug-in/MacRuby Preference Pane')
        end
      end
    end
  end
end