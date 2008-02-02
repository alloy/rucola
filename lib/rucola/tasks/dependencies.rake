require 'rucola/dependencies'

namespace :dependencies do
  THIRD_PARTY_DIR = (RUBYCOCOA_ROOT + 'vendor/third_party/').to_s
  
  def dependencies_holder
    deps = Rucola::Dependencies.load((RUBYCOCOA_ROOT + 'config/dependencies.rb').to_s)
    deps.resolve!
    deps
  end
  
  def file_types_from_env
    ENV['FILE_TYPES'].split(',').map {|t| t.strip.to_sym } unless ENV['FILE_TYPES'].nil?
  end
  
  desc "Lists all the dependencies and their required files. Use the FILE_TYPES env var to specify which files you'd like to include."
  task :list do
    Rucola::Dependencies.verbose = false
    
    str = ''
    dependencies_holder.dependencies.each do |dep|
      str += "\nDependency '#{dep.pretty_print_name}' requires the following files:\n\n"
      dep.required_files_of_types(file_types_from_env).each { |file| str += "  #{file.full_path}\n" }
    end
    puts str
  end
  
  desc "Copies all the required files to 'vendor/third_party/'. Use the FILE_TYPES env var to specify which files you'd like to include."
  task :copy do
    FileUtils.mkdir_p(THIRD_PARTY_DIR) unless File.exist?(THIRD_PARTY_DIR)
    $VERBOSE = nil # we don't want all the warnings about constant being redefined.
    dependencies_holder.copy_to(THIRD_PARTY_DIR, :types => file_types_from_env)
  end
  
  desc "Removes the 'vendor/third_party/' directory."
  task :clean do
    FileUtils.rm_rf(THIRD_PARTY_DIR) if File.exist?(THIRD_PARTY_DIR)
  end
end