require File.expand_path('../test_helper', __FILE__)
require "rucola/test_case"

class ATestController < OSX::NSObject
  ib_outlet :anOutlet
end

module SimulateTestUnit
  def self.included(klass)
    klass.send(:include, Mocha::Standalone)
    klass.extend Rucola::TestCase
  end
end

class ATestCase
  include SimulateTestUnit
  tests ATestController
end

class ATestCaseWithCustomSetupAndTeardown
  include SimulateTestUnit
  tests ATestController
  
  def setup
    :aliased
  end
  
  def teardown
    :aliased
  end
end

describe "The OSX::NSObject test case extensions" do
  it "should override ::ib_outlet and add defined outlets to ::defined_ib_outlets" do
    
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

describe "A Rucola::TestCase instance, in general" do
  before do
    @test_case = ATestCase.new
  end
  
  it "should return the class to be tested" do
    @test_case.class_to_be_tested.should.be ATestController
  end
  
  it "should return, and cache, an instance of the class to be tested" do
    instance = @test_case.instance_to_be_tested
    instance.should.be.instance_of ATestController
    @test_case.instance_to_be_tested.should.be instance
  end
  
  it "should have #instance_to_be_tested aliased as #controller" do
    @test_case.instance_to_be_tested.should.be @test_case.controller
  end
  
  it "should return an instance variable from the #instance_to_be_tested without the need for the `@' in the name" do
    object = mock('From an ivar')
    @test_case.instance_to_be_tested.instance_variable_set(:@an_ivar, object)
    
    @test_case.assigns(:an_ivar).should.be object
  end
  
  it "should assign an instance variable to the #instance_to_be_tested without the need for the `@' in the name" do
    object = mock('From an ivar')
    @test_case.assigns(:an_ivar, object)
    @test_case.instance_to_be_tested.instance_variable_get(:@an_ivar).should.be object
  end
end

describe "A Rucola::TestCase instance, concerning IB outlets" do
  before do
    @test_case = ATestCase.new
    
    @outlet_object = mock('From a IB outlet')
    @test_case.ib_outlet(:anOutlet, @outlet_object)
  end
  
  it "should assign the given value as an instance variable to the #instance_to_be_tested" do
    @test_case.assigns(:anOutlet).should.be @outlet_object
  end
  
  it "should create a private accessor method for an outlet on the test case" do
    @test_case.private_methods.should.include 'anOutlet'
    @test_case.send(:anOutlet).should.be @outlet_object
  end
  
  it "should mass create/assign outlets" do
    @test_case.expects(:ib_outlet).with(:outlet1, 'outlet1')
    @test_case.expects(:ib_outlet).with(:outlet2, 'outlet2')
    
    @test_case.ib_outlets :outlet1 => 'outlet1', :outlet2 => 'outlet2'
  end
  
  it "should assign Mocha’s stub_everything stubs to all outlets in ::defined_ib_outlets during #setup" do
    @test_case.setup
    stub = @test_case.send(:anOutlet)
    
    stub.should.be.instance_of Mocha::Mock
    stub.some_method_which_definitely_not_exists.should.be nil
  end
  
  it "should set all outlets in ::defined_ib_outlets to nil during #teardown" do
    @test_case.teardown
    @test_case.send(:anOutlet).should.be nil
  end
end