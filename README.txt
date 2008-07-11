= Rucola: A Framework for rapidly building RubyCocoa applications

Rucola is a light weight framework that helps you write RubyCocoa apps.
It allows you to build, test, and deploy applications using rake commands, 
eliminating the need to use XCode for the most common tasks.

Rucola provides a set of generators to help you generate controllers, window controllers, 
and document-based applications.  It also provides APIs for simplifying some of Objective-C's 
ways of doing things.

== Generating an application skeleton

    rucola MyApp -a "Your Name"

Running this command will give you a complete, working application with a single window already 
bound to your application controller.

== Working with Interface Builder

A Cocoa application contains `outlets`.  Outlets allow you to bind variable names to objects.
An object can be a user interface element or an instance of a class.

    class ApplicationController < Rucola::RCController
      ib_outlet :main_window

      def awakeFromNib
        puts "ApplicationController awoke."
        puts "Edit: app/controllers/application_controller.rb"
        puts  "\nIt's window is: #{@main_window.inspect}"
      end
    end

The `@main_window` variable now points to the user interface window.  You can invoke any methods of NSWindow.

There is also a `rake ib:update` that will update your nib files with the outlets you specify in your code.
For example, if we wanted to add a button to the application controller above, we could add `ib_outlet :my_button`.
After you've added this, you can run `rake ib:update` and your outlet will be available in interface builder that 
you can now hook up to your UI button.

== Building your application

To build your application, Rucola provides a simple rake command.  (You can also build your application in XCode)

    rake xcode:build

(Or simply use `rake` since xcode:build is the default task.)
This will compile and run your application.  At the moment we don't bundle Ruby or the gems that you are using 
in your application, we have plans to support this in order to make it really easy to distribute your application.

== Extras

Browse the git repo online at: http://github.com/alloy/rucola/tree/master

The latest version can be checked out with:

    $ git clone git://github.com/alloy/rucola.git

Sample apps can be found at (old svn repo):

    $ svn co svn://rubyforge.org/var/svn/rucola/extras/examples/

There's a basic TextMate bundle which contains only 4 commands which are the equivalent of the "go to file" commands in the rails bundle. With these going from a controller to it's test/model/view file is only a shortcut away. To get it:

    $ cd ~/Library/Application\ Support/TextMate/Bundles/
    $ svn co svn://rubyforge.org/var/svn/rucola/extras/Rucola.tmbundle

There's a crash reporter plugin and a ActiveRecord plugin available, which you can install with script/plugin install. Use script/plugin list to see the ones available.
