namespace :xcode do
  
  desc 'Builds the application'
  task :build do
    config = RUBYCOCOA_ENV.capitalize
    sh "xcodebuild -configuration #{config}"
    # get the users build dir
    prefs = OSX::NSUserDefaults.standardUserDefaults
    prefs.addSuiteNamed 'com.apple.xcode'
    build_dir = prefs['PBXApplicationwideBuildSettings']['SYMROOT'] || './build'
    # launch app with the correct env set
    sh "RUBYCOCOA_ENV='#{RUBYCOCOA_ENV}' RUBYCOCOA_ROOT='#{RUBYCOCOA_ROOT}' #{build_dir}/#{config}/#{TARGET}/Contents/MacOS/#{APPNAME}"
  end
  
end