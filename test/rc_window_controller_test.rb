#!/usr/bin/env macruby

require File.expand_path('../test_helper', __FILE__)

class FooBarController < Rucola::RCWindowController; end

describe 'A subclassed WindowController' do
  it "should know at initialization which nib belongs to it" do
    controller = FooBarController.alloc
    controller.expects('initWithWindowNibPath:owner:').with((Rucola::RCApp.root_path + 'app/views/FooBar.nib').to_s, controller).returns(true)
    controller.init
  end
end
