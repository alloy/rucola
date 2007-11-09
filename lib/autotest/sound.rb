# Original idea by Jeremy Seitz.
# See: http://fozworks.com/2007/7/28/autotest-sound-effects

require 'osx/cocoa'
require 'autotest'

# To use this autotest plugin add the following to your autotest config file (~/.autotest):
#
#   require 'autotest/sound'
module Autotest::Sound
  # Override this to specify an alternative path to your hook sounds.
  #
  #  def self.sound_path
  #    '/System/Library/Sounds'
  #  end
  def self.sound_path
    '/System/Library/Sounds'
  end
  
  # Override this to specify the sounds for the hooks.
  #
  #  def self.hook_sounds
  #    {
  #      #:run => 'Purr',
  #      :red => 'Basso.aiff',
  #      :green => 'Blow.aiff',
  #      :quit => 'Submarine.aiff',
  #      :run_command => 'Purr.aiff',
  #      #:ran_command => 'Morse.aiff'
  #    }
  #  end
  def self.hook_sounds
    {
      #:run => sound('Purr'),
      :red => 'Basso.aiff',
      :green => 'Blow.aiff',
      :quit => 'Submarine.aiff',
      :run_command => 'Purr.aiff',
      #:ran_command => 'Morse.aiff'
    }
  end
  
  hook_sounds.each_key do |hook|
    Autotest.add_hook(hook) do |at|
      if hook_sounds.has_key?(hook)
        snd = OSX::NSSound.alloc.initWithContentsOfFile_byReference( File.join(File.expand_path(sound_path), hook_sounds[hook]), true )
        snd.play
        sleep 0.25 while snd.playing?
      end
    end
  end
end
