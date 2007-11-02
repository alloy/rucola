require File.dirname(__FILE__) + '/test_helper.rb'

class FooBarController < Rucola::RCWindowController; end

describe 'A subclassed WindowController' do
  it "should know at initialization which nib belongs to it" do
    RUBYCOCOA_ROOT = ''
    
    FooBarController.during_init do |obj|
      obj.expects(:initWithWindowNibPath_owner).with('app/views/FooBar.nib', obj).returns(true)
    end
  end
end
