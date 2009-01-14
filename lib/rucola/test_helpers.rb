module Kernel
  # Silences any warnings that might have been thrown during the execution of the block.
  # This can be handy, for instance, for when you are re-defining constants.
  def silence_warnings
    before, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = before
  end
  
  # Stub ENV for the duration of the block.
  def with_env_var(name, value = 'true')
    before, ENV[name] = ENV[name], value
    yield
  ensure
    if before
      ENV[name] = before
    else
      ENV.delete(name)
    end
  end
  
  # Stub Rucola::RCApp.env (+RUCOLA_ENV+) for the duration of the block.
  def with_env(env)
    before = ::RUCOLA_ENV
    silence_warnings { Object.const_set('RUCOLA_ENV', env) }
    yield
  ensure
    silence_warnings { Object.const_set('RUCOLA_ENV', before) }
  end
  
  # Stub Rucola::RCApp.root_path (+RUCOLA_ROOT+) for the duration of the block.
  def with_root(root)
    before = ::RUCOLA_ROOT
    silence_warnings { Object.const_set('RUCOLA_ROOT', Pathname.new(root)) }
    yield
  ensure
    silence_warnings { Object.const_set('RUCOLA_ROOT', before) }
  end
end