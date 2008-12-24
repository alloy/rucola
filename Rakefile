namespace :dev_dependencies do
  desc 'Install development dependencies'
  task :install => [:test_spec, :mocha]
  
  task :bacon do
    version = '1.1.0'
    get "http://rubyforge-files.ruby-forum.com/test-spec/bacon-#{version}.tar.gz"
    install "/tmp/bacon-#{version}/lib/bacon.rb"
  end
  
  task :test_spec do
    version = '0.9.0'
    get "http://files.rubyforge.vm.bytemark.co.uk/test-spec/test-spec-#{version}.tar.gz"
    install "/tmp/test-spec-#{version}/lib/test"
  end
  
  task :mocha do
    version = '0.9.3'
    get "http://files.rubyforge.mmmultiworks.com/mocha/mocha-#{version}.tgz"
    mocha = "/tmp/mocha-#{version}"
    FileList["#{mocha}/lib/*.rb", "#{mocha}/lib/mocha"].each { |f| install f }
  end
  
  private
  
  def get(url)
    file = File.basename(url)
    sh "curl #{url} -o /tmp/#{file}"
    # for some reason mocha extracts with some junk...
    puts `cd /tmp && tar -zxvf #{file}`
  end
  
  def install(path)
    cp_r path, '/Library/Frameworks/MacRuby.framework/Versions/Current/usr/lib/ruby/site_ruby/'
  end
end