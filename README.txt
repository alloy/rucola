## Rucola: Framework for writing Cocoa applications in Ruby

SUPER DUPER PRE ALPHA VERSION (expect things to break kinda alpha...)

Rucola is a light weight framework that helps you write RubyCocoa apps.
It allows you to build, test, and deploy applications using rake commands, 
eliminating the need to use XCode, however you can use XCode if you wish.

Rucola provides a set of generators to help you generate controllers, window controllers, 
and document-based applications.  It also provides APIs for simplifying some of Objective-C's 
ways of doing things.

### Generating an application skeleton

    rucola MyApp -a "Your Name"

Running this command will give you a complete, working application with a single window already 
bound to your application controller.


### Using Notifications

    //Rucola
    class Foo < Rucola::RCController
      notify :some_method, :when => :something_happens
  
      def some_method(notification)
        puts "w00t!"
      end
    end

    //Objective C (Excluding header file)
    @implementation Foo
    -(id)init {
      if(self = [super init]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:(some_method:) name:@"SomethingHappensNotification" object:nil];
      }
      return self;
    }
    
    -(void)some_method:(NSNotification *) notification {
      NSLog("w00t!");
    }
    @end

### Alternative Way Of Using Notifications

    //Rucola
    class Foo < Rucola::RCController
      notify_on :something_happens do |notification|
        puts "w0t0!"
      end
    end

### Working with Interface Builder

A Cocoa application contains `outlets`.  Outlets allow you to bind variable names to objects.
An object can be a user interface element or an instance of a class.

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

The `@main_window` variable now points to the user interface window.  You can invoke any methods of NSWindow.

There is also a `rake ib:update` that will update your nib files with the outlets you specify in your code.
For example, if we wanted to add a button to the application controller above, we could add `ib_outlet :my_button`.
After you've added this, you can run `rake ib:update` and your outlet will be available in interface builder that 
you can now hook up to your UI button.

### Configuring your application
If you plan on using additional objective-c frameworks (WebKit, etc.) or ruby gems, you'll need to add these 
in your environment.rb file.

config.objc_frameworks = %w(WebKit IOKit)
config.use_active_record = true

### Building your application

To build your application, Rucola provides a simple rake command.  (You can also build your application in XCode)

    rake xcode:build

(Or simply use `rake` since xcode:build is the default task.)
This will compile and run your application.  At the moment we don't bundle Ruby or the gems that you are using 
in your application, we have plans to support this in order to make it really easy to distribute your application.

### Extras

Browse the svn repo online at: http://rucola.rubyforge.org/svn/

The latest version can be checked out with:

    $ svn co svn://rubyforge.org/var/svn/rucola/trunk rucola

Sample apps can be found at:

    $ svn co svn://rubyforge.org/var/svn/rucola/extras/examples/

There's a basic TextMate bundle which contains only 4 commands which are the equivalent of the "go to file" commands in the rails bundle. With these going from a controller to it's test/model/view file is only a shortcut away. To get it:

    $ cd ~/Library/Application\ Support/TextMate/Bundles/
    $ svn co svn://rubyforge.org/var/svn/rucola/extras/Rucola.tmbundle

There's a crash reporter plugin and a ActiveRecord plugin available, which you can install with script/plugin install. Use script/plugin list to see the ones available.
    