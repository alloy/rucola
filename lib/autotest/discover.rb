class Autotest
  # because we also have a config/environment.rb file
  # autotest tries to load autotest/rails_rucola
  @@discoveries = [] if File.exist? 'config/Info.plist'
end

Autotest.add_discovery do
  "rucola" if File.exist? 'config/Info.plist'
end