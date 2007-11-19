require File.expand_path('../test_helper', __FILE__)
require 'rucola/initializer'

describe 'Initializer' do
  it "should run any before and after boot plugins around the call to do_boot" do
    Rucola::Plugin.expects(:before_boot)
    Rucola::Initializer.expects(:do_boot)
    Rucola::Plugin.expects(:after_boot)
    Rucola::Initializer.boot
  end
end