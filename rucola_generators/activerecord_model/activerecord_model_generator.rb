require 'rubygems'
require 'rucola/rucola_support'
require 'rucola/info_plist'

class ActiverecordModelGenerator < RubiGen::Base
  
  default_options :author => nil
  
  attr_reader :name, :proxy_name, :app_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @name = args.shift
    @proxy_name = @name.camel_case + "Proxy"
    @app_name = Rucola::InfoPlist.open(destination_path('Info.plist')).data['CFBundleExecutable'].snake_case
    extract_options
  end

  def manifest
    record do |m|
      model_dir   = "app/models"
      config_dir  = "config"
      migrate_dir = "db/migrate"
      
      # Ensure appropriate folder(s) exists
      m.directory model_dir
      m.directory migrate_dir
      m.directory config_dir

      # Create stubs
      m.template "model_template.rb.erb",  "#{model_dir}/#{@name.snake_case}.rb"
      m.template "model_proxy_template.rb.erb",  "#{model_dir}/#{@proxy_name.snake_case}.rb"
      unless File.exists?(destination_path(config_dir) + '/database.yml')
        m.template "database.yml.erb", "#{config_dir}/database.yml"
      end
      
      m.migration_template "model_create_migration.rb.erb", "db/migrate", :migration_file_name => "create_#{@name.tableize}"
    end
  end

  protected
    def banner
      <<-EOS
USAGE: #{$0} #{spec.name} name

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