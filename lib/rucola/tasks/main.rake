require 'rake/testtask'

require 'osx/cocoa'
require 'rucola/xcode'
require 'rucola/nib'
require 'rucola/rucola_support'

# set the env, default to debug if we are running a rake task.
if ARGV[0] && %w{ release deploy }.include?(ARGV[0])
  mode = 'release'
  
  # we don't want the app to be started if we are deploying.
  ENV['DONT_START_RUBYCOCOA_APP'] = 'true' if ARGV[0] == 'deploy'
else
  ENV['RUBYCOCOA_ENV']  ||= 'debug'
  ENV['RUBYCOCOA_ROOT'] ||= SOURCE_ROOT
  
  mode = ENV['RUBYCOCOA_ENV']
end
puts "Running in mode: #{mode}\n\n"

# Load the applications Info.plist file
INFO_PLIST = OSX::NSDictionary.dictionaryWithContentsOfFile(File.join(SOURCE_ROOT, 'Info.plist'))

# Set some application defaults for the rake tasks
APPNAME    = INFO_PLIST['CFBundleExecutable']
APPVERSION = INFO_PLIST['CFBundleVersion']
TARGET     = "#{APPNAME}.app"

# Now that the env is set let initializer do it's work
require 'rucola/initializer'

# FIXME: We also need to check if the user uses a frozen rc framework
RUBYCOCOA_FRAMEWORK = OSX::NSBundle.bundleWithIdentifier('com.apple.rubycocoa').bundlePath.to_s

# TASKS

# Get all the tasks
Dir["#{File.dirname(__FILE__)}/*.rake"].each {|file| load file unless ['main.rake'].include? File.basename(file) }
Dir[(SOURCE_ROOT + '/vendor/plugins/*/tasks/*.rake').to_s].each { |r| load r }

task :default => 'xcode:build'

desc 'Runs all the clean tasks'
task :clean => ['xcode:clean', 'dependencies:clean', 'deploy:clean']

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*/test_*.rb']
  t.options = '-rr'
  t.verbose = true
end

desc 'Update any missing/changed files, if you updated from an earlier version of Rucola.1'
task :update do
  sh "cd .. && rucola #{File.basename(SOURCE_ROOT)}"
end
