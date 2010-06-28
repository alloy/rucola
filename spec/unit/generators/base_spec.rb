# encoding: UTF-8
require File.expand_path("../../../spec_helper", __FILE__)
require 'rucola/generators/base'

module FruityGens
  class BananaGenerator < Rucola::Generators::Base
  end
end

describe "Rucola::Generators::Base" do
  it "inherits from Thor::Group" do
    Rucola::Generators::Base.superclass.should == Thor::Group
  end
  
  it "returns the generator namespace" do
    FruityGens::BananaGenerator.base_name.should == 'fruity_gens'
  end
  
  it "returns the generator name" do
    FruityGens::BananaGenerator.generator_name.should == 'banana'
  end
  
  it "returns the root of the generators" do
    FruityGens::BananaGenerator.base_root.should == File.join(ROOT, 'lib/rucola/generators')
  end
  
  it "returns the generator source_root, named after the generator" do
    expected = File.join(ROOT, 'lib/rucola/generators/fruity_gens/banana/templates')
    File.expects(:exist?).with(expected).returns(true)
    FruityGens::BananaGenerator.source_root.should == expected
  end
end