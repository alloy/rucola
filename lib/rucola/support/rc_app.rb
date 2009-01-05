module Rucola
  module RCApp
    extend self
    
    # Returns the current RUCOLA_ENV, which normally is `debug' during development, `test' in the tests and `release' in a release.
    def env; RUCOLA_ENV; end
    
    # Returns whether or not the current env is `test'.
    def test?; env == 'test'; end
    
    # Returns whether or not the current env is `debug'.
    def debug?; env == 'debug'; end
    
    # Returns whether or not the current env is `release'.
    def release?; env == 'release'; end
    
    # Returns the path to the current source root of the application.
    #
    # So in debug & test mode this will point to your development source root.
    #
    # In release however this will point to the equivalent of:
    # <tt>NSBundle.mainBundle.resourcePath</tt>
    def root_path
      RUCOLA_ROOT
    end
    
    # Returns a Pathname containing the path to the app/controllers dir.
    #
    # So in debug & test mode this will point to your development
    # source_root/app/controllers.
    #
    # In release however this will point to the equivalent of:
    #   NSBundle.mainBundle.resourcePath + 'app/controllers'
    def controllers_path
      root_path + 'app/controllers'
    end
    
    # Returns a Pathname containing the path to the app/models dir.
    #
    # So in debug & test mode this will point to your development
    # source_root/app/models.
    #
    # In release however this will point to the equivalent of:
    #   NSBundle.mainBundle.resourcePath + 'app/models'
    def models_path
      root_path + 'app/models'
    end
    
    # Returns a Pathname containing the path to the app/assets dir.
    #
    # So in debug & test mode this will point to your development
    # source_root/app/assets.
    #
    # In release however this will point to the equivalent of:
    #   NSBundle.mainBundle.resourcePath + 'app/assets'
    def assets_path
      root_path + 'app/assets'
    end
    
    # Returns a Pathname containing the path to the current used app/views dir.
    #
    # So in debug & test mode this will point to your development
    # source_root/app/views.
    #
    # In release however this will point to the equivalent of:
    #   NSBundle.mainBundle.resourcePath + 'app/views'
    def views_path
      root_path + 'app/views'
    end
    
    # Returns a Pathname containing the path to the vendor/plugins dir.
    #
    # So in debug & test mode this will point to your development
    # source_root/vendor/plugins.
    #
    # In release however this will point to the equivalent of:
    #   NSBundle.mainBundle.resourcePath + 'vendor/plugins'
    def plugins_path
      root_path + 'vendor/plugins'
    end
    
    # Returns the path to a +controller+ file.
    #
    #   Rucola::RCApp.path_for_controller(ApplicationController) #=> 'root/app/controllers/application_controller.rb'
    def path_for_controller(controller)
      "#{controllers_path}/#{controller.name.to_s.snake_case}.rb"
    end
    
    # Returns the path to a +model+ file.
    #
    #   Rucola::RCApp.path_for_model(Person) #=> 'root/app/models/person.rb'
    def path_for_model(model)
      "#{models_path}/#{model.name.to_s.snake_case}.rb"
    end
    
    # Returns the path to a +view+ file.
    #
    #   Rucola::RCApp.path_for_controller('preferences') #=> 'root/app/views/Preferences.nib'
    #   Rucola::RCApp.path_for_controller('Preferences') #=> 'root/app/views/Preferences.nib'
    #
    #   Rucola::RCApp.path_for_controller(PreferencesController) #=> 'root/app/views/Preferences.nib'
    #   Rucola::RCApp.path_for_controller(PreferencesController.alloc.init) #=> 'root/app/views/Preferences.nib'
    def path_for_view(view)
      view = view.class unless view.is_a?(String) or view.is_a?(Class)
      view = view.name.to_s.sub(/Controller$/, '') if view.is_a? Class
      "#{views_path}/#{view.camel_case}.nib"
    end
    
    # Returns the path to an +asset+ file.
    #
    #   Rucola::RCApp.path_for_asset('somefile.png') #=> 'root/app/assets/somefile.png'
    def path_for_asset(asset)
      "#{assets_path}/#{asset}"
    end

    # Returns the name of the application as specified in the Info.plist file.
    #
    #   Rucola::RCApp.app_name #=> 'MyApp'
    def app_name
      Rucola::InfoPlist.open((root_path + 'config/Info.plist').to_s).app_name
    end
    
    # Returns the path to the application support directory for this application.
    #
    #   Rucola::RCApp.application_support_path #=> '/Users/eddy/Library/Application Support/MyApp/'
    def application_support_path
      File.join File.expand_path('~/Library/Application Support'), app_name
    end
  end
end