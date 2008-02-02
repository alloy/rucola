require 'rucola/dependencies'

namespace :dependencies do
  def file_types_from_env
    ENV['FILE_TYPES'].split(',').map {|t| t.strip.to_sym } unless ENV['FILE_TYPES'].nil?
  end
  
  desc "Lists all the dependencies and their required files. Use the FILE_TYPES env var to specify which files you'd like to include."
  task :list do
    Rucola::Dependencies.verbose = false
    deps = Rucola::Dependencies.load(SOURCE_ROOT + '/config/dependencies.rb')
    deps.resolve!
    
    str = ''
    deps.dependencies.each do |dep|
      str += "\nDependency '#{dep.name}#{' (' + dep.version + ')' unless dep.version == '>=0'}' requires the following files:\n\n"
      dep.required_files_of_types(file_types_from_env).sort_by {|f| f.full_path }.each { |file| str += "  #{file.full_path}\n" }
    end
    puts str
  end
end