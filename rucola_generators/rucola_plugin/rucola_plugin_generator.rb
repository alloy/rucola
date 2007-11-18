require 'rucola/rucola_support'

class RucolaPluginGenerator < RubiGen::Base
  
  default_options :author => nil
  
  attr_reader :name, :plugin_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @name = args.shift.snake_case
    @plugin_name = @name.camel_case
    extract_options
  end

  def manifest
    record do |m|
      plugin_dir = "vendor/plugins/#{name}"
      # Ensure appropriate folder(s) exists
      m.directory plugin_dir
      m.directory "#{plugin_dir}/generators"
      m.directory "#{plugin_dir}/lib"
      m.directory "#{plugin_dir}/tasks"
      if @rspec
        m.directory "#{plugin_dir}/spec"
      else
        m.directory "#{plugin_dir}/test"
      end

      # Create stubs
      m.template "init.rb.erb",  "#{plugin_dir}/init.rb"
    end
  end

  protected
    def banner
      <<-EOS
Creates a Rucola plugin in your apps vendor/plugins directory.

!!! NOTE: Rucola is still very young, and we may (will probably) modify how plugins work.
!!!       Please give feedback on the mailing list or in #ruby-osx on freenode

USAGE: #{$0} #{spec.name} name
EOS
    end

    def add_options!(opts)
      opts.separator ''
      opts.separator 'Options:'
      # For each option below, place the default
      # at the top of the file next to "default_options"
      opts.on("-r", "--rspec", "Create spec directory rather than test") { |v| options[:rspec] = v }
      # opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end
    
    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      @rspec = options[:rspec]
    end
end