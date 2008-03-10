# Perform any release specific tasks here.

Rucola::Initializer.run do |config|
  # Declare which dependency types should be bundled with a release build.
  # Most of the times you would probably only bundle gems if you're targeting
  # a ruby which is compatible and contains the right site libs.
  #
  # config.dependency_types = :gem, :standard, :other
  #
  # You can completely disable the usage of rubygems by setting this to false.
  # Unless you're using gems which are installed on a system by default, it's
  # better to set it to false. This will enable you to debug wether or not your
  # application has been bundled succesfully, PLUS not using rubygems will improve
  # the performance of your application.
  #
  # config.use_rubygems = false
end