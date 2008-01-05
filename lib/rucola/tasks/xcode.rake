namespace :xcode do
  
  def config
    RUBYCOCOA_ENV.capitalize
  end
  
  def build_dir
    # get the users build dir
    prefs = OSX::NSUserDefaults.standardUserDefaults
    prefs.addSuiteNamed 'com.apple.xcode'
    # first check if there are any xcode prefs at all.
    if prefs['PBXApplicationwideBuildSettings']
      prefs['PBXApplicationwideBuildSettings']['SYMROOT'] || './build'
    else
      './build'
    end
  end
  
  def build_root
    File.expand_path("#{build_dir}/#{config}/#{TARGET}")
  end
  
  desc 'Builds the application'
  task :build do
    executable = "#{build_root}/Contents/MacOS/#{APPNAME}"
    
    # For now let's do xcodebuild everytime.
    # Otherwise nibs that are updated will not be updated in the bundle...
    sh "xcodebuild -configuration #{config}"
    
    # unless File.exists?(executable)
    #   sh "xcodebuild -configuration #{config}"
    # else
    #   puts "Build already exists, skipping. (Use clean if you really really want a new build.)\n\n"
    # end
    
    # Make sure the app is brought to the front once launched.
    Thread.new(executable) do |executable|
      sleep 0.025 until OSX::NSWorkspace.sharedWorkspace.launchedApplications.any? {|dict| dict['NSApplicationName'] == APPNAME }
      `osascript -e 'tell application "#{executable}" to activate'`
    end
    
    # launch app with the correct env set
    sh "RUBYCOCOA_ENV='#{RUBYCOCOA_ENV}' RUBYCOCOA_ROOT='#{RUBYCOCOA_ROOT}' #{executable}"
  end
  
  desc 'Removes the build'
  task :clean do
    puts "Removing #{build_root}"
    FileUtils.rm_rf build_root
  end
  
  namespace :frameworks do
    desc "Add any framework in vendor/frameworks which isn't in the project yet to the project and bundle it"
    task :update do
      if File.exist? 'vendor/frameworks'
        project = Rucola::Xcode.new File.join(SOURCE_ROOT, "#{APPNAME}.xcodeproj")
        framework_names = project.frameworks.map { |f| f.last['name'] }
        changes = false
        FileList['vendor/frameworks/*.framework'].each do |framework|
          framework_name = File.basename(framework)
          unless framework_names.include?(framework_name)
            changes = true
            puts "Adding #{framework_name} to project."
            project.add_framework(framework_name, framework)
            project.bundle_framework(framework_name)
          end
        end
        project.save if changes
      end
    end
  end
end