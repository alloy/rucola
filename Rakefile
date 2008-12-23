namespace :dev_dependencies do
  desc 'Install development dependencies'
  task :install => :bacon
  
  task :bacon do
    version = '1.1.0'
    get "http://rubyforge-files.ruby-forum.com/test-spec/bacon-#{version}.tar.gz"
    install "/tmp/bacon-#{version}/lib/bacon.rb"
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