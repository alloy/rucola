require File.join(File.dirname(__FILE__), "test_generator_helper.rb")

class FooBarController < Rucola::WindowController::Base; end

describe 'A subclassed WindowController' do
  it "should know at initialization which nib belongs to it" do
    RUBYCOCOA_ROOT = ''
    instance = FooBarController.alloc
    instance.expects(:initWithWindowNibPath_owner).with('app/views/FooBar.nib', instance)
    instance.init
  end
end
