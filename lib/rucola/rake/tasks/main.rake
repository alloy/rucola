desc "Default task is xcode:run"
task :default => 'xcode:run'

desc "Load the environment"
task :environment do
  Rucola::Initializer.process
end

puts "\nRunning in `#{RUCOLA_ENV}' environment.\n\n"