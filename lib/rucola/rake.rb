module Rucola
  module Rake
    autoload :Builder, 'rucola/rake/lib/builder'
  end
end

if defined?(Rake)
  Dir.glob(File.expand_path('../rake/tasks/*.rake', __FILE__)).each do |tasks|
    load tasks
  end
end