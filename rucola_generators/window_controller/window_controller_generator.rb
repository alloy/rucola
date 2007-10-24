require 'rubygems'
require 'rucola/rucola_support/core_ext/string'
require 'rucola/keyed_objects_nib'

class WindowControllerGenerator < RubiGen::Base
  
  default_options :author => nil
  
  attr_reader :name
  
  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @name = args.shift
    extract_options
  end

  def manifest
    record do |m|
      # Ensure appropriate folder(s) exists
      controller_dir = 'app/controllers'
      view_dir       = 'app/views'
      test_dir       = 'test/controllers'
      
      m.directory controller_dir
      m.directory view_dir
      m.directory test_dir
      
      m.template 'window_controller_template.rb.erb', "#{controller_dir}/#{@name.snake_case}_controller.rb"
      m.template 'test_window_controller_template.rb.erb', "#{test_dir}/test_#{@name.snake_case}_controller.rb"
      
      controller_name_camel = @name.camel_case
      nib = "#{view_dir}/#{controller_name_camel}.nib"
      m.directory nib
      m.template  'Window.nib/classes.nib.erb',  "#{nib}/classes.nib"
      m.file      'Window.nib/info.nib',         "#{nib}/info.nib"

      # Add the Foo.nib/keyedobjects.nib file and set the custom class of File's Owner to the new controller class.
      original_nib, new_nib = source_path('Window.nib/keyedobjects.nib'), destination_path("#{nib}/keyedobjects.nib")
      logger.create new_nib
      keyed_objects_nib = Rucola::KeyedObjectsNib.open(original_nib)
      keyed_objects_nib.change_files_owner_class("#{controller_name_camel}Controller")
      keyed_objects_nib.save(new_nib)
    end
  end

  protected
    def banner
      <<-EOS
Creates a ...

USAGE: #{$0} #{spec.name} name"
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