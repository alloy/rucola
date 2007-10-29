namespace :rc do
  
  namespace :freeze do
    
    RUBYCOCOA_FRAMEWORK_PATH_CURRENT = 'vendor/rubycocoa'
    desc "Freezes the current used version of RubyCocoa in #{RUBYCOCOA_FRAMEWORK}"
    task :current do
      mkdir_p RUBYCOCOA_FRAMEWORK_PATH_CURRENT unless File.exist? RUBYCOCOA_FRAMEWORK_PATH_CURRENT
      puts "Copying framework."
      cp_r RUBYCOCOA_FRAMEWORK, RUBYCOCOA_FRAMEWORK_PATH_CURRENT
      # add the new RubyCocoa framework to the project and bundle it when building the application
      Rake::Task['rc:freeze:bundle'].invoke
    end
    
    RUBYCOCOA_FRAMEWORK_PATH_EDGE = 'vendor/rubycocoa/framework/build/Default'
    desc 'Freezes the current edge version of RubyCocoa'
    task :edge do
      if File.exist? 'vendor/rubycocoa'
        sh 'cd vendor/rubycocoa && svn up'
      else
        mkdir 'vendor' unless File.exist? 'vendor'
        sh 'cd vendor && svn co https://rubycocoa.svn.sourceforge.net/svnroot/rubycocoa/trunk/src rubycocoa'
      end
      sh 'cd vendor/rubycocoa && rake'
      
      # add the new RubyCocoa framework to the project and bundle it when building the application
      Rake::Task['rc:freeze:bundle'].invoke
    end
    
    desc 'Bundle the frozen RubyCocoa framework with the application'
    task :bundle do
      if File.exist? RUBYCOCOA_FRAMEWORK_PATH_EDGE
        framework_location = RUBYCOCOA_FRAMEWORK_PATH_EDGE
      else
        framework_location = RUBYCOCOA_FRAMEWORK_PATH_CURRENT
      end
      project = Rucola::Xcode.new File.join(SOURCE_ROOT, "#{APPNAME}.xcodeproj")
      project.change_rubycocoa_framework_location "#{framework_location}/RubyCocoa.framework"
      project.bundle_rubycocoa_framework
      project.save
    end
  end
  
end