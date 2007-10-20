require File.expand_path('../../test_helper', __FILE__)

class TestApplicationController < Test::Unit::TestCase
  
  def test_application_controller_initialization
    application_controller = ApplicationController.alloc.init
    assert_instance_of(ApplicationController, application_controller)
  end
  
end