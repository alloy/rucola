require File.expand_path('../../test_helper', __FILE__)

describe 'ApplicationController' do
  tests ApplicationController
  
  # If necessary, you can setup custom objects for the ib_outlets defined in the class.
  # Note however that by using 'tests ApplicationController' all the outlets will get stubbed
  # with stubs that respond to every message with nil.
  #
  # def after_setup
  #   ib_outlets :window => mock("Main Window"),
  #              :tableView => OSX::NSTableView.alloc.init,
  #              :searchField => OSX::NSSearchField.alloc.init
  # 
  #   window.stubs(:title => 'Main Window')
  #   tableView.addTableColumn OSX::NSTableColumn.alloc.init
  #   searchField.stringValue = "foo"
  # end
  
  it "should initialize" do
    controller.should.be.an.instance_of ApplicationController
  end
  
  it "should set itself as the application delegate" do
    OSX::NSApp.expects(:delegate=).with(controller)
    controller.ib_outlet(:main_window).expects(:inspect)
    controller.awakeFromNib
  end
  
  it "should do some stuff when the application has finished launching" do
    Kernel.expects(:puts)
    controller.applicationDidFinishLaunching(nil)
  end
  
  it "should do some stuff when the application will terminate" do
    Kernel.expects(:puts)
    controller.applicationWillTerminate(nil)
  end
end