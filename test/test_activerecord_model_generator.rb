require File.join(File.dirname(__FILE__), "test_generator_helper.rb")

class TestActiverecordModelGenerator < Test::Unit::TestCase
  include RubiGen::GeneratorTestHelper

  def setup
    bare_setup
    setup_info_plist
  end
  
  def teardown
    bare_teardown
  end
  
  def test_generator_without_model_name_shows_usage
    assert_raise RubiGen::UsageError do
      run_generator('activerecord_model', [], sources)
    end
  end

  def test_generator_with_model_name_creates_model_directory
    name = "FooBar"
    run_generator('activerecord_model', [name], sources)
    assert_directory_exists 'app/models'
  end
      
  def test_generator_with_model_name_creates_model
    name = "FooBar"
    run_generator('activerecord_model', [name], sources)
    assert_generated_file 'app/models/foo_bar.rb' do |file|
      assert_equal "class FooBar < ActiveRecord::Base\nend", file
    end
  end

  def test_generator_with_model_name_creates_proxy
    name = "FooBar"
    run_generator('activerecord_model', [name], sources)
    assert_generated_file 'app/models/foo_bar_proxy.rb' do |file|
      assert_equal "class FooBarProxy < OSX::ActiveRecordProxy\nend", file
    end
  end

  def test_generator_with_model_name_creates_migration_dir
    name = "FooBar"
    run_generator('activerecord_model', [name], sources)
    assert_directory_exists 'db/migrate'
  end
  
  def test_generator_with_model_name_creates_migration
    name = "FooBar"
    run_generator('activerecord_model', [name], sources)
    assert_generated_file 'db/migrate/001_create_foo_bars.rb' do |file|
      assert_has_method(file, 'self.up', 'self.down')
      assert_match /class CreateFooBars < ActiveRecord::Migration/, file
    end
  end

  def test_generator_with_snake_case_model_name_creates_migration
    name = "foo_bar"
    run_generator('activerecord_model', [name], sources)
    assert_generated_file 'db/migrate/001_create_foo_bars.rb' do |file|
      assert_has_method(file, 'self.up', 'self.down')
      assert_match /class CreateFooBars < ActiveRecord::Migration/, file
    end
  end
  
  def test_generator_with_model_name_creates_config_database_yml_if_it_does_not_exist
    name = "foo_bar"
    run_generator('activerecord_model', [name], sources)
    assert_directory_exists 'config'
    assert_generated_file 'config/database.yml' do |file|
      assert_match %r{  database: my_test_debug}, file
      assert_match %r{  database: my_test_test}, file
      assert_match %r{  database: my_test}, file
    end
  end
  
  private
  def sources
    [RubiGen::PathSource.new(:test, File.join(File.dirname(__FILE__),"..", generator_path))
    ]
  end
  
  def generator_path
    "rucola_generators"
  end
  
  def setup_info_plist
    File.open(APP_ROOT + '/Info.plist', 'w+') do |file|
      file.write <<-EOF
      <plist version="1.0">
      <dict>
      	<key>CFBundleDevelopmentRegion</key>
      	<string>English</string>
      	<key>CFBundleExecutable</key>
      	<string>MyTest</string>
      </dict>
      </plist>
EOF
    end
  end
end
