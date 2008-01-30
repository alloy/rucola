require 'rucola/dependencies'

namespace :dependencies do
  desc 'Lists all the dependencies and their required files'
  task :list do
    Rucola::Dependencies.verbose = false
    dependencies = Rucola::Dependencies.load(SOURCE_ROOT + '/config/dependencies.rb')
    puts dependencies.list
  end
end