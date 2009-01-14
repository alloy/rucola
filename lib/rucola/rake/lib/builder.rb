require 'objc_ext/ns_user_defaults'

module Rucola
  module Rake
    class Builder
      # Returns a Pathname instance with the path to the build directory.
      #
      # If the user has configured a global build dir in XCode.app that is
      # returned, otherwise defaults to the build directory in the source root:
      #
      #   Rucola::RCApp.root_path + 'build'
      def self.build_root
        defaults = NSUserDefaults.standardUserDefaults
        defaults.addSuiteNamed 'com.apple.xcode'
        
        if defaults['PBXApplicationwideBuildSettings'] &&
              (root = defaults['PBXApplicationwideBuildSettings']['SYMROOT'])
          Pathname.new(root)
        else
          Rucola::RCApp.root_path + 'build'
        end
      end
      
      # Returns a new Builder instance with for specified environment. Defaults
      # to <tt>Rucola::RCApp.env</tt>
      def initialize(env = Rucola::RCApp.env)
        @env = env
      end
      
      # Builds the application with the configuration for the current
      # environment using the +xcodebuild+ tool.
      def build
        sh "xcodebuild -configuration #{configuration}"
      end
      
      # Runs the build of the current configuration.
      def run
        sh(release? ? executable : "#{environment_parameters} '#{executable}'")
      end
      
      # Returns the configuration to be used, which is a capitalized version
      # of the current environment.
      def configuration
        @env.capitalize
      end
      
      # Returns the +RUCOLA_ENV+ and +RUCOLA_ROOT+ environment parameters:
      #
      #  "RUCOLA_ENV='debug' RUCOLA_ROOT='/path/to/source/root'"
      def environment_parameters
        "RUCOLA_ENV='#{@env}' RUCOLA_ROOT='#{Rucola::RCApp.root_path}'"
      end
      
      # Returns a Pathname instance with the path to the application bundle for
      # the current environment.
      def application_bundle
        self.class.build_root + configuration + "#{Rucola::RCApp.app_name}.app"
      end
      
      # Returns a Pathname instance with the path to the application's
      # executable:
      #
      #   Rucola::RCApp.root_path + 'build/Debug/MyApp.app/Contents/MacOS/MyApp'
      def executable
        application_bundle + "Contents/MacOS/#{Rucola::RCApp.app_name}"
      end
      
      private
      
      def release?
        @env == 'release'
      end
    end
  end
end