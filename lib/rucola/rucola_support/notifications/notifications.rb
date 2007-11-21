require 'osx/cocoa'

module Rucola
  module Notifications
    # This Notifications module will add a class method called +notify_on+, which registers
    # your object for the given notification and executes the given block when the
    # notification is posted to the OSX::NSNotificationCenter.defaultCenter.
    #
    #   class FooController < OSX::NSObject
    #
    #     notify_on OSX::NSApplicationDidFinishLaunchingNotification do |notification|
    #       puts "Application did finish launching."
    #       p notification
    #     end
    #
    #     # code
    #
    #   end
    #   
    #   In addition to notify_on, you also get a method called notify which allows you to specify methods
    #   to be invoked when a notification is posted.
    #     
    #     class FooController < OSX::NSObject
    #       notify :some_method, :when => :application_did_finish_launching
    #     
    #       def some_method(notification)
    #         puts "Application finished launching"
    #       end
    #     end


      module ClassMethods
        # Add prefix shortcuts as a hash.
        #
        #   class FooController < OSX::NSObject
        #     acts_as_notifiable
        #
        #     # This will make sure that :win_ is expanded to :window_ in the notifications that you register.
        #     notification_prefix :win => :window
        #
        #     when :win_did_become_key do |notification|
        #       # code
        #     end
        #   end
        #
        # By default the shortcut <tt>{ :app => :application }</tt> is registered.
        def notification_prefix(prefixes)
          (@_notification_prefixes ||= {}).merge! prefixes
        end
        
        # Creates a notification and posts it to the reciever
        def fire_notification(notification, obj)
          notification_name = resolve_notification_name(notification)
          OSX::NSNotificationCenter.defaultCenter.postNotificationName_object(notification_name, obj)
        end
        alias_method :post_notification, :fire_notification
        
        # Registers the object for the given notification and executes the given block when the
        # notification is posted to the OSX::NSNotificationCenter.defaultCenter.
        #
        #   class FooController < OSX::NSObject
        #
        #     notify_on OSX::NSApplicationDidFinishLaunchingNotification do |notification|
        #       puts "Application did finish launching."
        #       p notification
        #     end
        #
        #     # code
        #
        #   end
        #
        # You can also pass it a symbol as +notification+ in which case it will be exapnded.
        # It will first check if the name + 'Notification' exists, if not it will prepend 'NS'.
        # So :application_did_finish_launching becomes 'NSApplicationDidFinishLaunchingNotification'.
        #
        # You can even register shortcut prefixes. See +notification_prefix+.
        def notify_on(notification, &block)
          
          notification_name = resolve_notification_name(notification)
          method_name = "_handle_#{notification_name.snake_case}".to_sym
          
          # define the handle method
          class_eval do
            define_method(method_name, &block)
          end
          
          @_registered_notifications ||= {}
          @_registered_notifications[notification_name.to_s] = method_name
        end
        
        # Registers the object for the given notification and executes the given block when the
        # notification is posted to the OSX::NSNotificationCenter.defaultCenter.
        #
        #   class FooController < OSX::NSObject
        #
        #     once OSX::NSApplicationDidFinishLaunchingNotification do |notification|
        #       puts "Application did finish launching."
        #       p notification
        #     end
        #
        #     # code
        #
        #   end
        #
        # You can also pass it a symbol as +notification+ in which case it will be exapnded.
        # It will first check if the name + 'Notification' exists, if not it will prepend 'NS'.
        # So :application_did_finish_launching becomes 'NSApplicationDidFinishLaunchingNotification'.
        #
        # You can even register shortcut prefixes. See +notification_prefix+.
        #
        # FIXME: Which is better +once+ or +notify_on+?
        alias_method :once, :notify_on
        
        # Register a callback when a notification is posted.
        #
        #     class FooController < OSX::NSObject
        #       notify :some_method, :when => :application_did_finish_launching
        #     
        #       def some_method(notification)
        #         puts "Application finished launching"
        #       end
        #     end
        #
        def notify(method_to_notify, options = {})
          @_registered_notifications ||= {}
          @_registered_notifications[options[:when]] = method_to_notify
        end
        
        protected

        # Given a symbol, attempt to map it to an NSNoficication, otherwise 
        # return the symbol if nothing is found.
        #
        #    :app_finished_launching => NSApplicationFinishLaunchingNotification
        def resolve_notification_name(name)
          return name if name.is_a?(String)
          notification_name = name.to_s

          # first check if this notification_name uses a shortcut prefix
          split_notification_name = notification_name.split('_')
          prefix = split_notification_name.first.to_sym
          if @_notification_prefixes and @_notification_prefixes.has_key? prefix
            notification_name = @_notification_prefixes[prefix].to_s << '_' << split_notification_name[1..-1].join('_')
          end

          begin
            # try with only Notification appended
            notification_name = notification_name.camel_case << 'Notification'
            OSX.const_get(notification_name)
            return notification_name
          rescue NameError
            # then try with NS prepended
            begin
              notification_name = 'NS' << notification_name
              OSX.const_get(notification_name)
              return notification_name
            rescue 
              
            end
          end
          return name
        end
        
      end
      
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        
        # register the initialize hook which actually registers the notifications for the instance.
        base._rucola_register_initialize_hook lambda { self._register_notifications }
        
        # register default shortcut
        base.notification_prefix :app => :application
      end
      
      # this instance method is called after object initialization by the initialize hook
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