require File.expand_path('../../spec_helper', __FILE__)
require 'rucola/vinegar'
include Rucola::Vinegar

class CocoaTestClass < NSObject
end

class VinegarTestObject < Rucola::Vinegar::Object
  proxy_for CocoaTestClass
  
  attr_accessor :main_ingredient, :total
  
  def total=(additive)
    @total = "#{main_ingredient} with #{additive}"
  end
end