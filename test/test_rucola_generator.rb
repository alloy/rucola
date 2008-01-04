require File.join(File.dirname(__FILE__), "test_generator_helper.rb")

module RubiGen::GeneratorTestHelper
  def assert_generated_symlink(path)
    # For some reason File.exists? doesn't work with symlinks generated with File.symlink(),
    # it does work if the symlink was created with: ln -s
    assert Dir.entries(File.dirname("#{APP_ROOT}/#{path}")).include?(File.basename(path)),"The symbolic link '#{path}' should exist"
  end
end

class TestRucolaGenerator < Test::Unit::TestCase
  include RubiGen::GeneratorTestHelper

  def setup
    bare_setup
  end
  
  def teardown
    bare_teardown
  end
  
  # Some generator-related assertions:
  #   assert_generated_file(name, &block) # block passed the file contents
  #   assert_directory_exists(name)
  #   assert_generated_class(name, &block)
  #   assert_generated_module(name, &block)
  #   assert_generated_test_for(name, &block)
  # The assert_generated_(class|module|test_for) &block is passed the body of the class/module within the file
  #   assert_has_method(body, *methods) # check that the body has a list of methods (methods with parentheses not supported yet)
  #
  # Other helper methods are:
  #   app_root_files - put this in teardown to show files generated by the test method (e.g. p app_root_files)
  #   bare_setup - place this in setup method to create the APP_ROOT folder for each test
  #   bare_teardown - place this in teardown method to destroy the TMP_ROOT or APP_ROOT folder after each test
  
  def test_generator_without_options
    run_generator('rucola', [APP_ROOT], sources)

    assert_directory_exists "app/controllers"
    assert_directory_exists "app/models"
    assert_directory_exists "app/views"
    assert_directory_exists "app/assets"
    
    assert_directory_exists "config/environments"
    assert_directory_exists "misc/English.lproj/MainMenu.nib"
    assert_directory_exists "test/controllers"
    assert_directory_exists "test/models"
    assert_directory_exists "lib"
    assert_directory_exists "vendor"

    assert_generated_file   "Rakefile"
    
    assert_generated_file   "app/controllers/application_controller.rb"
    assert_generated_file   "config/boot.rb"
    assert_generated_file   "config/environment.rb"
    assert_generated_file   "config/environments/debug.rb"
    assert_generated_file   "config/environments/release.rb"
    assert_generated_file   "config/environments/test.rb"
    assert_generated_file   "config/Info.plist"
    assert_generated_file   "config/ib_external_class_defs.yml"
    assert_generated_symlink "Info.plist"

    assert_generated_file   "misc/main.m"
    assert_generated_file   "misc/rb_main.rb"
    assert_generated_file   "misc/English.lproj/InfoPlist.strings"
    assert_generated_file   "misc/English.lproj/MainMenu.nib/classes.nib"
    assert_generated_file   "misc/English.lproj/MainMenu.nib/info.nib"
    assert_generated_file   "misc/English.lproj/MainMenu.nib/keyedobjects.nib"
    
    assert_directory_exists "myproject.xcodeproj"
    assert_generated_file   "myproject.xcodeproj/project.pbxproj"
    
    assert_generated_file   "test/test_helper.rb"
    assert_generated_file   "test/controllers/test_application_controller.rb"
    
    assert_directory_exists "script"
    assert_generated_file   "script/plugin"
    assert `ls -l #{File.expand_path('../tmp/myproject/script/plugin', __FILE__)}`[0..9] == '-rwxr-xr-x'
  end
  
  private
  def sources
    [RubiGen::PathSource.new(:test, File.join(File.dirname(__FILE__),"..", generator_path))
    ]
  end
  
  def generator_path
    "app_generators"
  end
end
