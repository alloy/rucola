module Rucola
  module RCApp
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
  end
end