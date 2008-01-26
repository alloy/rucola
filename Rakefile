require 'config/requirements'
require 'config/hoe' # setup Hoe + all gem configuration
require 'rake/testtask'

Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end
 
def remove_task(task_name)
  Rake.application.remove_task(task_name)
end

Dir['tasks/**/*.rake'].each { |rake| load rake }

remove_task :test

Rake::TestTask.new do |t|
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
  #t.options = '-rr'
end

# desc 'First uninstalls the currently installed Rucola gem and then installs the new one.'
# task :install_gem_test do
#   if `rake check_manifest`.split("\n").length == 1
#     sh 'gem uninstall rucola'
#     Rake::Task['install_gem_no_doc'].invoke
#   else
#     puts "You first might need to update the manifest!"
#   end
# end