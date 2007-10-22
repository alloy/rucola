require "rubygems"
require "test/unit"
require "test/spec"
require "mocha"

require "rucola/rucola_support/window_controller"

class FooBarController < Rucola::WindowController::Base; end

describe 'A subclassed WindowController' do
  it "should know at initialization which nib belongs to it" do
    RUBYCOCOA_ROOT = ''
    instance = FooBarController.alloc
    instance.expects(:initWithWindowNibPath_owner).with('app/views/FooBar.nib', instance)
    instance.init
  end
end
