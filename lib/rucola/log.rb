require 'singleton'

module Rucola
  # The Log class is basically a wrapper around NSLog. It is a singleton class so you should get an instance using the instance
  # class method instead of new.
  #
  #   Rucola::Log.instance.fatal("Couldn't initialize application.")
  #
  # The Log class is generally accessed through the log method on Kernel.
  #
  #   log.debug("%d exceptions caught, giving up", exceptions.length)
  class Log
    DEBUG = 0
    INFO = 1
    WARN = 2
    ERROR = 3
    FATAL = 4
    UNKNOWN = 5
    SILENT = 9
    
    include Singleton
    
    # Holds the current log level
    attr_accessor :level
    
    # Creates a new Log instance. Don't call this directly, call instance instead.
    #
    #   log.instance
    def initialize
      @level = level_for_env
    end
    
    def debug(*args); log(DEBUG, *args); end
    def info(*args); log(INFO, *args); end
    def warn(*args); log(WARN, *args); end
    def error(*args); log(ERROR, *args); end
    def fatal(*args); log(FATAL, *args); end
    def unknown(*args); log(UNKNOWN, *args); end
    
    # Returns default log level for the application environment.
    #
    #   log.level_for_env #=> Log::ERROR
    def level_for_env
      case Rucola::RCApp.env
      when 'test'
        SILENT
      when 'debug'
        DEBUG
      when 'release'
        ERROR
      end
    end
    
    # Writes a message to the log is the current loglevel is equal or greater than the message_level.
    #
    #   log.log(Log::DEBUG, "This is a debug message")
    def log(message_level, *args)
      NSLog(*args) if message_level >= level
    end
  end
end