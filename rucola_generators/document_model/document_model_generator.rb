require 'rucola/rucola_support'
require 'rucola/info_plist'

class DocumentModelGenerator < RubiGen::Base
  
  default_options :author => nil
  
  attr_reader :name
  
  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty? || args.length == 1
    @name = args.shift
    @extension = args.shift
    extract_options
  end

  def manifest
    record do |m|
      model_dir      = 'app/models'
      view_dir       = 'app/views'
      test_dir       = 'test/models'
      
      m.directory model_dir
      m.directory view_dir
      m.directory test_dir

      # run the window controller generator
      m.dependency 'window_controller', [@name]
      
      m.template 'document_model_template.rb.erb', "#{model_dir}/#{@name.snake_case}.rb"
      m.template 'test_document_model_template.rb.erb', "#{test_dir}/test_#{@name.snake_case}.rb"
      
      # add the document to the Info.plist
      info_plist = Rucola::InfoPlist.open(destination_path('config/Info.plist'))
      info_plist.add_document_type(@name.camel_case, @extension, 'Editor')
      info_plist.save
    end
  end

  protected
    def banner
      <<-EOS
Creates a model that inherits from NSDocument.

USAGE: #{$0} #{spec.name} name extension"
EOS
    end

    def add_options!(opts)
      # opts.separator ''
      # opts.separator 'Options:'
      # For each option below, place the default
      # at the top of the file next to "default_options"
      # opts.on("-a", "--author=\"Your Name\"", String,
      #         "Some comment about this option",
      #         "Default: none") { |options[:author]| }
      # opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end
    
    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
    end
end