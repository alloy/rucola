require File.expand_path('../test_helper', __FILE__)
require 'rucola/plugin'

include Rucola

class FooPlugin < Rucola::Plugin
end

describe 'Plugin' do
  it "contains list of plugin subclasses" do
    Rucola::Plugin.plugins.map { |p| p.class }.should == [FooPlugin]
  end
end