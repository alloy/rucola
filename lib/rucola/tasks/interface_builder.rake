require 'yaml'

namespace :ib do
  RB_NIB_TOOL = "#{RUBYCOCOA_FRAMEWORK}/Versions/Current/Tools/rb_nibtool.rb"
  
  def helper_file
    "/tmp/#{APPNAME}_helper.rb.tmp"
  end
  
  def create_tmp_helper_file
    # get all the Rucola controller class definition files
    class_defs = FileList["#{File.expand_path('../../rucola_support/controllers', __FILE__)}/*.rb"]
    
    # get the optional ib_external_class_defs.yml file in which a user can specify any other
    # classes that might need to be incuded for IB to recognize them.
    user_class_def_string = ''
    user_class_def_file = File.join(SOURCE_ROOT, 'config/ib_external_class_defs.yml')
    user_class_defs = YAML.load_file(user_class_def_file)
    if user_class_defs
      user_class_defs.each do |klass, superklass|
        user_class_def_string += "class #{klass} < #{superklass}; end\n"
      end
    end
    
    # write the Rucola controllers and the optional ib_external_class_defs.yml to a tmp file
    File.open(helper_file, 'w') do |file|
      file.write class_defs.map{ |class_def| File.read(class_def) }.join("\n\n") << user_class_def_string
    end
  end
  
  def create_tmp_controller_file(controller_name)
    tmp_file = "/tmp/#{controller_name.snake_case}.rb.tmp"
    File.open(tmp_file, 'w') do |file|
      file.write( File.read(helper_file) + "\n\n" + File.read("app/controllers/#{controller_name.snake_case}.rb") )
    end
    tmp_file
  end
  
  def name_for_controller(controller_path)
    File.basename(controller_path)[0..-4].camel_case
  end
  
  desc 'Updates the nibs from their corresponding ruby source files'
  task :update do
    create_tmp_helper_file
    
    controllers = FileList["#{SOURCE_ROOT}/app/controllers/*.rb"]
    nibs = FileList["#{SOURCE_ROOT}/app/views/*.nib", "#{SOURCE_ROOT}/misc/English.lproj/MainMenu.nib"].reject {|file| File.extname(file) != '.nib' or file.include? '~' }
    
    controllers.each do |controller_path|
      controller_name = name_for_controller(controller_path)
      nibs.each do |nib|
        if Rucola::Nib::Classes.open("#{nib}/classes.nib").has_class? controller_name
          @tmp_file ||= create_tmp_controller_file(controller_name)
          puts "      update  #{nib[(SOURCE_ROOT.length + 1)..-1]}: #{controller_name}"
          `ruby #{RB_NIB_TOOL} --update --nib #{nib} --file #{@tmp_file}`
        end
      end
      @tmp_file = nil
    end
  end
  
end