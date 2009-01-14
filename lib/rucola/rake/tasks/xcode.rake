namespace :xcode do
  desc 'Builds the application'
  task :build do
    Rucola::Rake::Builder.new.build
  end
  
  desc 'Run the application build'
  task :run => :build do
    Rucola::Rake::Builder.new.run
  end
end