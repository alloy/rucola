require File.expand_path('../test_helper', __FILE__)

class SomeDocController < Rucola::RCWindowController; end
class SomeDoc < Rucola::RCDocument; end

describe "RCDocument" do
  it "should initialize a window controller corresponding to itself" do
    # doc = SomeDoc.alloc
    # doc.expects(:addWindowController).with(SomeDocController)
    # doc.init
    
    doc = SomeDoc.alloc.init
    controller_mock = mock("SomeDocController mock")
    SomeDocController.expects_alloc_init_returns(controller_mock)
    doc.expects(:addWindowController).with(controller_mock)
    doc.makeWindowControllers
  end
end