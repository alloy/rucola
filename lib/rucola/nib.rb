require 'osx/cocoa'
require 'fileutils'

module Rucola
  module Nib  #:nodoc:
    
    def self.backup(path)
      nib = File.dirname(path)
      nib_name = File.basename(nib)
      backup = "/tmp/#{nib_name}.bak"
      unless $TESTING
        puts "\n========================================================================="
        puts "Backing up #{nib} to #{backup}"
        puts "Please retrieve that one if for some reason the nib was damaged!"
        puts "=========================================================================\n\n"
      end
      FileUtils.rm_rf(backup) if File.exists?(backup)
      FileUtils.cp_r(nib, backup)
    end
    
    class Classes #:nodoc:
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
      
      def add_class(class_name, superclass_name = 'NSObject')
        classes.push({
          'CLASS' => class_name,
          'SUPERCLASS' => superclass_name,
          'LANGUAGE' => 'ObjC'
        })
      end
      
      def has_class?(class_name)
        classes.any? { |klass| klass['CLASS'] == class_name }
      end
      
      def save
        Rucola::Nib.backup(@path)
        @data.writeToFile_atomically(@path, true)
      end
      
    end
    
    class KeyedObjects #:nodoc:
      attr_reader :data
      
      def self.open(path)
        new(path)
      end
      
      def initialize(path)
        @path = path
        @data, format, error = OSX::NSPropertyListSerialization.propertyListFromData_mutabilityOption_format_errorDescription(
          OSX::NSData.dataWithContentsOfFile(@path),
          OSX::NSPropertyListMutableContainersAndLeaves
        )
      end
      
      def files_owner_class
        @data['$objects'][3]
      end
      
      # Changes the custom class of the File's Owner.
      def change_files_owner_class(new_class)
        # With a fresh nib the name of the custom class always appears as the 4th object
        # in the $objects array. But this might not always be the case. At least for
        # setting the initial custom class with a known nib, such as the one we use
        # as a template, will work.
        @data['$objects'][3] = new_class
      end
      
      # Save the keyedobjects.nib back to the original path.
      # Or alternatively pass it a new path.
      def save(new_path = nil)
        new_data, new_error = OSX::NSPropertyListSerialization.dataFromPropertyList_format_errorDescription(@data, OSX::NSPropertyListBinaryFormat_v1_0)

        Rucola::Nib.backup(@path)

        path = (new_path.nil? ? @path : new_path)
        dirname = File.dirname(path)
        FileUtils.mkdir_p(dirname) unless File.exists?(dirname)

        new_data.writeToFile_atomically(path, true)
      end
    end
  end
end