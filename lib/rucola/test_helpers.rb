module Kernel
  # Stub the Rucola::RCApp.env (+RUCOLA_ENV+) for the duration of the block.
  def with_env(env)
    before = ::RUCOLA_ENV
    silence_warnings { Object.const_set('RUCOLA_ENV', env) }
    yield
    silence_warnings { Object.const_set('RUCOLA_ENV', before) }
  end
  
  # Silences any warnings that might have been thrown during the execution of the block.
  # This can be handy, for instance, for when you are re-defining constants.
  def silence_warnings
    before = $VERBOSE
    $VERBOSE = nil
    yield
    $VERBOSE = before
  end
end