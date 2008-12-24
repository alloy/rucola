module Rucola
  class InfoPlist
    def self.open(path)
      new(path)
    end
    
    attr_reader :data
    
    def initialize(path)
      @path = path
      @data = NSDictionary.dictionaryWithContentsOfFile(@path)
    end
    
    def document_types
      @data['CFBundleDocumentTypes'] ||= []
      @data['CFBundleDocumentTypes']
    end
    
    def add_document_type(name, extension, role, icon = '????', os_type = '????')
      document_types.push({
        'NSDocumentClass' => name,
        'CFBundleTypeExtensions' => [extension],
        'CFBundleTypeRole' => role,
        'CFBundleTypeIconFile' => icon,
        'CFBundleTypeOSTypes' => [os_type],
        'CFBundleTypeName' => 'DocumentType'
      })
    end
    
    def save
      @data.writeToFile(@path, atomically: true)
    end
    
    # Returns the name of the application (CFBundleExecutable).
    def app_name
      @data['CFBundleExecutable']
    end
  end
end