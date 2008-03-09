require 'rucola/log'

module Kernel
  # Returns a logger instance
  #
  # Examples:
  #
  #   log.level = Rucola::Log::DEBUG
  #   log.info "Couldn't load preferences, using defaults"
  #   log.debug "Initiating primary foton drive…"
  #
  # For more information see the Rucola::Log class.
  def log
    Rucola::Log.instance
  end
end