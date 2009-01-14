desc "Default task is xcode:run"
task :default => 'xcode:run'

desc "Load the environment"
task :environment do
  Rucola::Initializer.process
end

desc "Clean the build directory"
task :clean do
  rm_rf Rucola::Rake::Builder.build_root
end

puts "\nRunning in `#{RUCOLA_ENV}' environment.\n\n"