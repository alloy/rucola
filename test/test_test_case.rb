require File.expand_path('../test_helper', __FILE__)
require "rucola/test_case"

class ATestController < OSX::NSObject
end

class ATestCase
  extend Rucola::TestCase
  tests ATestController
end

describe "Rucola::TestCase" do
  before do
    @test_case = ATestCase.new
  end
  
  it "should define a public setup method and a private alias" do
    ATestCase.instance_methods.should.include 'setup'
    ATestCase.private_instance_methods.should.include 'rucola_test_case_setup'
  end
  
  it "should define a public teardown method and a private alias" do
    ATestCase.instance_methods.should.include 'teardown'
    ATestCase.private_instance_methods.should.include 'rucola_test_case_teardown'
  end
  
  it "should alias a new user defined #setup method to #after_setup and re-alias Rucola's setup to #setup" do
    @test_case.should.not.respond_to :after_setup
    ATestCase.class_eval { def setup; :aliased end }
    @test_case.after_setup.should.be :aliased
    
    @test_case.expects(:after_setup)
    @test_case.setup
  end
  
  it "should alias a new user defined #teardown method to #after_teardown and re-alias Rucola's teardown to #teardown" do
    @test_case.should.not.respond_to :after_teardown
    ATestCase.class_eval { def teardown; :aliased end }
    @test_case.after_teardown.should.be :aliased
    
    @test_case.expects(:after_teardown)
    @test_case.teardown
  end
end