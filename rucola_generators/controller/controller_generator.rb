require 'rubygems'
require 'rucola/rucola_support'
require 'rucola/nib'

class ControllerGenerator < RubiGen::Base
  
  default_options :author => nil
  
  attr_reader :name
  
  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @name = args.shift
    @nibs_to_update = args
    extract_options
  end

  def add_class_to_classes_nib(controller_name, nib_path)
    nib = Rucola::Nib::Classes.open(File.expand_path(destination_path(nib_path)))
    nib.add_class(controller_name)
    nib.save
  end

  def manifest
    record do |m|
      # Ensure appropriate folder(s) exists
      controller_dir = 'app/controllers'
      test_dir       = 'test/controllers'
      
      m.directory controller_dir
      m.directory test_dir

      # Create stubs
      m.template 'controller_template.rb.erb', "#{controller_dir}/#{@name.snake_case}_controller.rb"
      m.template 'test_controller_template.rb.erb', "#{test_dir}/test_#{@name.snake_case}_controller.rb"
      
      # Optionally add the class to a nib
      controller_name = "#{@name.camel_case}Controller"
      if @nibs_to_update.empty?
        print "\nWould you like me to add the class #{controller_name} to MainMenu.nib? [Y/n]: " unless $TESTING
        result = Kernel.gets.strip
        if result.empty? or result.downcase == 'y'
          add_class_to_classes_nib(controller_name, 'misc/English.lproj/MainMenu.nib/classes.nib')
        end
      else
        @nibs_to_update.each do |nib|
          if nib.camel_case == 'MainMenu'
            add_class_to_classes_nib(controller_name, 'misc/English.lproj/MainMenu.nib/classes.nib')
          else
            add_class_to_classes_nib(controller_name, "app/views/#{nib.camel_case}.nib/classes.nib")
          end
        end
      end
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