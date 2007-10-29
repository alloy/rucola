require 'rake/testtask'

require 'osx/cocoa'
require 'rucola/xcode'
require 'rucola/nib'
require 'rucola/rucola_support'

# set the env, default to debug if we are running a rake task.
RUBYCOCOA_ENV = ENV['RUBYCOCOA_ENV'].nil? ? 'debug' : ENV['RUBYCOCOA_ENV']
RUBYCOCOA_ROOT = ENV['RUBYCOCOA_ROOT'].nil? ? SOURCE_ROOT : ENV['RUBYCOCOA_ROOT']
puts "RUNNING IN MODE: #{RUBYCOCOA_ENV.upcase}\n\n"

# FIXME: We also need to check if the user uses a frozen rc framework
RUBYCOCOA_FRAMEWORK = OSX::NSBundle.bundleWithIdentifier('com.apple.rubycocoa').bundlePath.to_s

# TASKS

# Get all the tasks
Dir["#{File.dirname(__FILE__)}/*.rake"].each {|file| load file unless File.basename(file) == 'main.rake' }

task :default => 'xcode:build'

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*/test_*.rb']
  t.verbose = true
end

