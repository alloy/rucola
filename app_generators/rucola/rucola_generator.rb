class RubiGen::Commands::Create
  def symlink(relative_source, relative_destination)
    return logger.identical(relative_destination) if File.exists?(destination_path(relative_destination))
    # We don't want the symlink to point to a full path,
    # so change to the destination_root and create the symlink.
    Dir.chdir(destination_root) { File.symlink relative_source, relative_destination }
  end
end

class RucolaGenerator < RubiGen::Base
  
  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])
  
  default_options :author => 'YOUR NAME'
  
  attr_reader :name, :project, :author
  
  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = File.expand_path(args.shift)
    @name = base_name
    @project = name
    extract_options
  end

  def manifest
    record do |m|
      # Ensure appropriate folder(s) exists
      m.directory ''
      BASEDIRS.each { |path| m.directory path }

      m.directory           'misc/English.lproj/MainMenu.nib' # TODO - allow alternate default languages

      # Create stubs
      m.template            "Rakefile.erb",  "Rakefile"
      
      m.file                "app/controllers/application_controller.rb", "app/controllers/application_controller.rb"
      m.file_copy_each      %w[boot.rb dependencies.rb environment.rb ib_external_class_defs.yml], "config"
      m.template            "config/Info.plist.erb", "config/Info.plist"
      m.symlink             "config/Info.plist", "Info.plist"
      
      m.file_copy_each      %w[debug.rb release.rb test.rb], "config/environments"

      #m.template_copy_each  %w[main.m.erb rb_main.rb.erb], "misc"
      m.template            "misc/main.m.erb", "misc/main.m"
      m.template            "misc/rb_main.rb.erb", "misc/rb_main.rb"

      # TODO - allow alternate default languages
      m.template            "misc/English.lproj/InfoPlist.strings.erb", "misc/English.lproj/InfoPlist.strings"
      m.file_copy_each      %w[classes.nib info.nib keyedobjects.nib], "misc/English.lproj/MainMenu.nib"

      # xocde project
      m.directory           "#{@project}.xcodeproj"
      m.template            "project.pbxproj.erb", "#{@project}.xcodeproj/project.pbxproj"

      # test
      m.file                "test/test_helper.rb", "test/test_helper.rb"
      m.file                "test/controllers/test_application_controller.rb", "test/controllers/test_application_controller.rb"
      
      copy_and_make_executable('script/plugin')
      copy_and_make_executable('script/console')
      
      m.dependency "install_rubigen_scripts", [destination_root, "rucola"], 
        :shebang => options[:shebang], :collision => :force
    end
  end

  def copy_and_make_executable(file)
    logger.create file
    FileUtils.mkdir_p File.dirname(destination_path(file))
    FileUtils.copy(source_path(file), destination_path(file))
    File.chmod(0755, destination_path(file))
  end
  
  protected
    def banner
      <<-EOS
Creates a basic RubyCocoa application skeleton.

USAGE: #{spec.name} name"
EOS
    end

    def add_options!(opts)
      opts.separator ''
      opts.separator 'Options:'
      # For each option below, place the default
      # at the top of the file next to "default_options"
      opts.on("-a", "--author=\"Your Name\"", String,
              "Places your name within some copyright headers.",
              "Default: YOUR NAME") { |options[:author]| }
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end
    
    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      @author = options[:author]
    end

    # Installation skeleton.  Intermediate directories are automatically
    # created so don't sweat their absence here.
    BASEDIRS = %w(
      app/controllers
      app/models
      app/views
      app/assets
      config/environments
      lib
      script
      test/controllers
      test/lib
      test/models
      vendor
    )
end