OSX.require_framework '/System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework'

module Rucola
  class FSEvents
    class FSEvent
      attr_reader :fsevents_object
      attr_reader :id
      attr_reader :path
      def initialize(fsevents_object, id, path)
        @fsevents_object, @id, @path = fsevents_object, id, path
      end
      
      # Returns an array of the files/dirs in the path that the event occurred in.
      # The files are sorted by the modification time, the first entry is the last modified file.
      def files
        Dir.glob("#{File.expand_path(path)}/*").sort_by {|f| File.mtime(f) }.reverse
      end
      
      # Returns the last modified file in the path that the event occurred in.
      def last_modified_file
        files.first
      end
    end
    
    class StreamError < StandardError; end
    
    attr_reader :paths
    attr_reader :stream
    
    attr_accessor :allocator
    attr_accessor :context
    attr_accessor :since
    attr_accessor :latency
    attr_accessor :flags
    
    class << self
      # Initializes a new FSEvents `watchdog` object,
      # creates, starts and then returns the stream.
      #
      # Pass it a block which will be used as a callback.
      # The block will receive an array of FSEvent objects.
      #
      #   fsevents = Rucola::FSEvents.start_watching('/some/path') do |events|
      #     events.each do |event|
      #       p event
      #     end
      #   end
      #   p fsevents
      def start_watching(*paths, &block)
        fsevents = new(paths.flatten, &block)
        fsevents.create_stream
        fsevents.start
        fsevents
      end
    end
    
    # Creates a new FSEvents `watchdog` object.
    # Pass it an array of paths and a block with your callback.
    def initialize(paths, &block)
      raise ArgumentError, 'No callback block was specified.' unless block_given?
      paths.each { |path| raise ArgumentError, "The specified path (#{path}) does not exist." unless File.exist?(path) }
      
      @allocator = OSX::KCFAllocatorDefault
      @context   = nil
      @since     = OSX::KFSEventStreamEventIdSinceNow
      @latency   = 0.0
      @flags     = 0
      @stream    = nil
      
      @paths = paths
      @user_callback = block
      @callback = Proc.new do |stream, client_callback_info, number_of_events, paths_pointer, event_flags, event_ids|
        paths_pointer.regard_as('*')
        events = []
        number_of_events.times {|i| events << Rucola::FSEvents::FSEvent.new(self, event_ids[i], paths_pointer[i]) }
        @user_callback.call(events)
      end
    end
    
    # Create the stream.
    # Raises a Rucola::FSEvents::StreamError if the stream could not be created.
    def create_stream
      @stream = OSX.FSEventStreamCreate(@allocator, @callback, @context, @paths, @since, @latency, @flags)
      raise(StreamError, 'Unable to create FSEvents stream.') unless @stream
      OSX.FSEventStreamScheduleWithRunLoop(@stream, OSX.CFRunLoopGetCurrent, OSX::KCFRunLoopDefaultMode)
    end
    
    # Start the stream.
    # Raises a Rucola::FSEvents::StreamError if the stream could not be started.
    def start
      raise(StreamError, 'Unable to start FSEvents stream.') unless OSX.FSEventStreamStart(@stream)
    end
    
    # Stop the stream.
    # You can resume it by calling `start` again.
    def stop
      OSX.FSEventStreamStop(@stream)
    end
  end
end
