require 'osx/cocoa'
require 'FileUtils'

module Rucola
  module Nib
    class Classes
      attr_reader :data
      
      def self.open(classes_nib_path)
        new(classes_nib_path)
      end
      
      def initialize(classes_nib_path)
        @path = File.expand_path(classes_nib_path)
        @data = OSX::NSDictionary.dictionaryWithContentsOfFile(@path)
      end
      
      def classes
        @data['IBClasses']
      end
      
      def add_class(class_name)
        classes.push({
          'CLASS' => class_name,
          'SUPERCLASS' => 'NSObject',
          'LANGUAGE' => 'ObjC'
        })
      end
      
      def save
        nib = File.dirname(@path)
        nib_name = File.basename(nib)
        backup = "/tmp/#{nib_name}.bak"
        unless $TESTING
          puts "\n========================================================================="
          puts "Backing up #{nib} to #{backup}"
          puts "Please retrieve that one if for some reason the nib was damaged!\n"
        end
        Kernel.system("rm -rf #{backup}") if File.exists?(backup)
        Kernel.system("cp -R #{nib} #{backup}")
        
        @data.writeToFile_atomically(@path, true)
      end
      
    end
  end
end