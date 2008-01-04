class OSX::NSImage
  class << self
    # This implementation adds app/assets to the search domain.
    # So if for instance you have an image app/assets/some_img.png,
    # you can then use OSX::NSImage.imageNamed('some_img') and it will be found.
    def imageNamed(name)
      if @assets_files.nil?
        @assets_files = {}
        Dir.glob("#{Rucola::RCApp.assets_path}/*.*").each do |file|
          basename = File.basename(file).gsub(/\..*/, '')
          @assets_files[basename] = file
        end
      end
    
      if image_file = @assets_files[name.to_s]
        alloc.initWithContentsOfFile image_file
      else
        super_imageNamed(name)
      end
    end
  end
end