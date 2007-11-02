namespace :xcode do
  
  def config
    RUBYCOCOA_ENV.capitalize
  end
  
  def build_dir
    # get the users build dir
    prefs = OSX::NSUserDefaults.standardUserDefaults
    prefs.addSuiteNamed 'com.apple.xcode'
    prefs['PBXApplicationwideBuildSettings']['SYMROOT'] || './build'
  end
  
  def build_root
    File.expand_path("#{build_dir}/#{config}/#{TARGET}")
  end
  
  desc 'Builds the application'
  task :build do
    executable = "#{build_root}/Contents/MacOS/#{APPNAME}"
    
    unless File.exists?(executable)
      sh "xcodebuild -configuration #{config}"
    else
      puts "Build already exists, skipping. (Use clean if you really really want a new build.)\n\n"
    end
    
    # Make sure the app is brought to the front once launched.
    Thread.new do
      sleep 0.025 until OSX::NSWorkspace.sharedWorkspace.launchedApplications.any? {|dict| dict['NSApplicationName'] == APPNAME }
      `osascript -e 'tell application "#{APPNAME}" to activate'`
    end
    
    # launch app with the correct env set
    sh "RUBYCOCOA_ENV='#{RUBYCOCOA_ENV}' RUBYCOCOA_ROOT='#{RUBYCOCOA_ROOT}' #{executable}"
  end
  
  desc 'Removes the build'
  task :clean do
    puts "Removing #{build_root}"
    FileUtils.rm_rf build_root
  end
end