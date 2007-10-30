require File.dirname(__FILE__) + '/test_helper.rb'

class FooBarController < Rucola::RCWindowController; end

describe 'A subclassed WindowController' do
  it "should know at initialization which nib belongs to it" do
    RUBYCOCOA_ROOT = ''
    instance = FooBarController.alloc
    instance.expects(:initWithWindowNibPath_owner).with('app/views/FooBar.nib', instance)
    instance.init
  end
end
