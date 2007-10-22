require 'rubygems'
require 'rucola/rucola_support/core_ext/string'

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
      
      nib = "#{view_dir}/#{@name.camel_case}.nib"
      m.directory nib
      m.template  'Window.nib/classes.nib.erb',  "#{nib}/classes.nib"
      m.file      'Window.nib/info.nib',         "#{nib}/info.nib"
      m.file      'Window.nib/keyedobjects.nib', "#{nib}/keyedobjects.nib"
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