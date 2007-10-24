require 'osx/cocoa'
require 'FileUtils'

module Rucola
  # KeyedObjectsNib provides a way to alter a keyedobjects.nib file.
  class KeyedObjectsNib
    # Returns a NSDictionary from the serialized plist.
    # Give it the path to the Foo.nib/keyedobjects.nib file.
    def self.plist_from_nib(path)
      data = OSX::NSData.dataWithContentsOfFile(path)
      plist, format, error = OSX::NSPropertyListSerialization.propertyListFromData_mutabilityOption_format_errorDescription(data, OSX::NSPropertyListMutableContainersAndLeaves)
      plist
    end
  
    def self.open(path)
      new(path)
    end
  
    def initialize(path)
      @path = path
      @plist = KeyedObjectsNib.plist_from_nib(@path)
    end
  
    # Changes the custom class of the File's Owner.
    def change_files_owner_class(new_class)
      # With a fresh nib the name of the custom class always appears as the 4th object
      # in the $objects array. But this might not always be the case. At least for
      # setting the initial custom class with a known nib, such as the one we use
      # as a template, will work.
      @plist['$objects'][3] = new_class
    end
  
    # Save the plist back to the original path.
    # Or alternatively pass it a new path for the output.
    def save(new_path = nil)
      new_data, new_error = OSX::NSPropertyListSerialization.dataFromPropertyList_format_errorDescription(@plist, OSX::NSPropertyListBinaryFormat_v1_0)
      
      path = (new_path.nil? ? @path : new_path)
      dirname = File.dirname(path)
      FileUtils.mkdir_p(dirname) unless File.exists?(dirname)
      
      new_data.writeToFile_atomically(path, true)
    end
  end
end