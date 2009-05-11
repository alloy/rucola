require File.expand_path('../test_helper', __FILE__)
require "rucola/test_case"

class ATestController < OSX::NSObject
end

class ATestCase
  extend Rucola::TestCase
  tests ATestController
end

class ATestCaseWithCustomSetupAndTeardown
  extend Rucola::TestCase
  tests ATestController
  
  def setup
    :aliased
  end
  
  def teardown
    :aliased
  end
end

describe "The Rucola::TestCase class" do
  before do
    @test_case = ATestCase.new
  end
  
  it "should register the class to test" do
    ATestCase.instance_variable_get(:@class_to_be_tested).should.be ATestController
  end
  
  it "should include the Rucola::TestCase::InstanceMethods module into the TestCase" do
    ATestCase.ancestors.should.include Rucola::TestCase::InstanceMethods
  end
  
  it "should define a public setup method and a private alias" do
    ATestCase.public_instance_methods.should.include 'setup'
    ATestCase.private_instance_methods.should.include 'rucola_test_case_setup'
  end
  
  it "should define a public teardown method and a private alias" do
    ATestCase.public_instance_methods.should.include 'teardown'
    ATestCase.private_instance_methods.should.include 'rucola_test_case_teardown'
  end
  
  it "should alias a new user defined #setup method to #after_setup" do
    ATestCase.public_instance_methods.should.not.include 'after_setup'
    
    test_case = ATestCaseWithCustomSetupAndTeardown.new
    test_case.after_setup.should.be :aliased
  end
  
  it "should re-alias Rucola's #rucola_test_case_setup to #setup" do
    test_case = ATestCaseWithCustomSetupAndTeardown.new
    test_case.expects(:after_setup)
    test_case.setup
  end
  
  it "should alias a new user defined #teardown method to #after_teardown" do
    ATestCase.public_instance_methods.should.not.include 'after_teardown'
    
    test_case = ATestCaseWithCustomSetupAndTeardown.new
    test_case.after_teardown.should.be :aliased
  end
  
  it "should re-alias Rucola's #rucola_test_case_teardown to #teardown" do
    test_case = ATestCaseWithCustomSetupAndTeardown.new
    test_case.expects(:after_teardown)
    test_case.teardown
  end
end
