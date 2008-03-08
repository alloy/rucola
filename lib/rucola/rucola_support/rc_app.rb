require 'rucola/info_plist'

module Rucola
  module RCApp
    # Returns the current RUBYCOCOA_ENV, which normally is 'debug' during development, test in the tests and 'release' in a release.
    def env; RUBYCOCOA_ENV; end
    module_function :env
    def test?; env == 'test'; end
    module_function :test?
    def debug?; env == 'debug'; end
    module_function :debug?
    def release?; env == 'release'; end
    module_function :release?
    
    # Returns the path to the current source root of the application.
    #
    # So in debug & test mode this will point to your development source root.
    #
    # In release however this will point to the equivalent of:
    # <tt>NSBundle.mainBundle.resourcePath</tt>
    def root_path
      RUBYCOCOA_ROOT.to_s
    end
    module_function :root_path
    
    # Returns the path to the current used app/controllers dir.
    #
    # So in debug & test mode this will point to your development
    # source_root/app/controllers.
    #
    # In release however this will point to the equivalent of:
    #   NSBundle.mainBundle.resourcePath + 'app/controllers'
    def controllers_path
      (RUBYCOCOA_ROOT + 'app/controllers').to_s
    end
    module_function :controllers_path
    
    # Returns the path to the current used app/models dir.
    #
    # So in debug & test mode this will point to your development
    # source_root/app/models.
    #
    # In release however this will point to the equivalent of:
    #   NSBundle.mainBundle.resourcePath + 'app/models'
    def models_path
      (RUBYCOCOA_ROOT + 'app/models').to_s
    end
    module_function :models_path
    
    # Returns the path to the current used app/assets dir.
    #
    # So in debug & test mode this will point to your development
    # source_root/app/assets.
    #
    # In release however this will point to the equivalent of:
    #   NSBundle.mainBundle.resourcePath + 'app/assets'
    def assets_path
      (RUBYCOCOA_ROOT + 'app/assets').to_s
    end
    module_function :assets_path
    
    # Returns the path to the current used app/views dir.
    #
    # So in debug & test mode this will point to your development
    # source_root/app/views.
    #
    # In release however this will point to the equivalent of:
    #   NSBundle.mainBundle.resourcePath + 'app/views'
    def views_path
      (RUBYCOCOA_ROOT + 'app/views').to_s
    end
    module_function :views_path
    
    # Returns the path to a +controller+ file.
    #
    #   Rucola::RCApp.path_for_controller(ApplicationController) #=> 'root/app/controllers/application_controller.rb'
    def path_for_controller(controller)
      "#{controllers_path}/#{controller.name.to_s.snake_case}.rb"
    end
    module_function :path_for_controller
    
    # Returns the path to a +model+ file.
    #
    #   Rucola::RCApp.path_for_model(Person) #=> 'root/app/models/person.rb'
    def path_for_model(model)
      "#{models_path}/#{model.name.to_s.snake_case}.rb"
    end
    module_function :path_for_model
    
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
    module_function :path_for_view
    
    # Returns the path to an +asset+ file.
    #
    #   Rucola::RCApp.path_for_asset('somefile.png') #=> 'root/app/assets/somefile.png'
    def path_for_asset(asset)
      "#{assets_path}/#{asset}"
    end
    module_function :path_for_asset

    # Returns the name of the application as specified in the Info.plist file.
    #
    #   Rucola::RCApp.app_name #=> 'MyApp'
    def app_name
      Rucola::InfoPlist.open((RUBYCOCOA_ROOT + 'config/Info.plist').to_s).app_name
    end
    module_function :app_name
  end
end