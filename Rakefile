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
  t.options = '-rr'
end