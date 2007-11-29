class ApplicationController < Rucola::RCController
  ib_outlet :main_window
  
  def awakeFromNib
    # All the application delegate methods will be called on this object.
    OSX::NSApp.delegate = self
    
    puts "ApplicationController awoke."
    puts "Edit: app/controllers/application_controller.rb"
    puts  "\nIts window is: #{@main_window.inspect}"
  end
  
  # NSApplication delegate methods
  def applicationDidFinishLaunching(notification)
    Kernel.puts "\nApplication finished launching."
  end
  
  def applicationWillTerminate(notification)
    Kernel.puts "\nApplication will terminate."
  end
  
end