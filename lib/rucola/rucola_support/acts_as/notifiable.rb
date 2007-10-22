require 'osx/cocoa'
require 'rucola/rucola_support/acts_as'
require 'rucola/rucola_support/core_ext/string'

module Rucola
  module ActsAs
    
    register_acts_as :notifiable do
      _register_notifications
    end
    
    # This ActsAs module will add a class method called +notify_on+, which registers
    # your object for the given notification and executes the given block when the
    # notification is posted to the OSX::NSNotificationCenter.defaultCenter.
    #
    #   class FooController < OSX::NSObject
    #     acts_as_notifiable
    #
    #     notify_on OSX::NSApplicationDidFinishLaunchingNotification do |notification|
    #       puts "Application did finish launching."
    #       p notification
    #     end
    #
    #     # code
    #
    #   end
    module Notifiable

      module ClassMethods
        # The ActsAs::Notifiable module will add a class method called +notify_on+, which registers
        # your object for the given notification and executes the given block when the
        # notification is posted to the OSX::NSNotificationCenter.defaultCenter.
        #
        #   class FooController < OSX::NSObject
        #     acts_as_notifiable
        #
        #     notify_on OSX::NSApplicationDidFinishLaunchingNotification do |notification|
        #       puts "Application did finish launching."
        #       p notification
        #     end
        #
        #     # code
        #
        #   end
        def notify_on(notification_name, &block)
          method_name = "_handle_#{notification_name.snake_case}".to_sym
          
          class_eval do
            define_method(method_name, &block)
          end
          
          @_registered_notifications ||= {}
          @_registered_notifications[notification_name.to_s] = method_name
        end
      end
      
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
      end
      
      def _register_notifications # :nodoc:
        notifications = self.class.instance_variable_get(:@_registered_notifications)
        return if notifications.nil?
        center = OSX::NSNotificationCenter.defaultCenter
        notifications.each do |notification_name, notification_handler|
          center.addObserver_selector_name_object(self, notification_handler, notification_name, nil)
        end
      end
    end
  end
end