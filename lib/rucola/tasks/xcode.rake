namespace :xcode do
  
  desc 'Builds the application'
  task :build do
    config = RUBYCOCOA_ENV.capitalize
    sh "xcodebuild -configuration #{config}"
    # get the users build dir
    prefs = OSX::NSUserDefaults.standardUserDefaults
    prefs.addSuiteNamed 'com.apple.xcode'
    build_dir = prefs['PBXApplicationwideBuildSettings']['SYMROOT'] || './build'
    
    # Make sure the app is brought to the front once launched.
    Thread.new do
      sleep 0.025 until OSX::NSWorkspace.sharedWorkspace.launchedApplications.any? {|dict| dict['NSApplicationName'] == APPNAME }
      `osascript -e 'tell application "#{APPNAME}" to activate'`
    end
    
    # launch app with the correct env set
    sh "RUBYCOCOA_ENV='#{RUBYCOCOA_ENV}' RUBYCOCOA_ROOT='#{RUBYCOCOA_ROOT}' #{build_dir}/#{config}/#{TARGET}/Contents/MacOS/#{APPNAME}"
  end
  
end