class ApplicationController < Rucola::RCController
  ib_outlet :main_window
  
  def awakeFromNib
    # All the application delegate methods will be called on this object.
    OSX::NSApp.delegate = self
    
    puts "ApplicationController awoke."
    puts "Edit: app/controllers/application_controller.rb"
    puts  "\nIt's window is: #{@main_window.inspect}"
  end
  
  # NSApplication delegate methods
  def applicationDidFinishLaunching(notification)
    puts "\nApplication finished launching."
  end
  
  def applicationWillTerminate(notification)
    puts "\nApplication will terminate."
  end
  
end