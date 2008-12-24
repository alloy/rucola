module Kernel
  # Stub the Rucola::RCApp.env (+RUCOLA_ENV+) for the duration of the block.
  def with_env(env)
    before = Rucola::RCApp.env
    Rucola::RCApp.stubs(:env).returns(env)
    yield
    Rucola::RCApp.stubs(:env).returns(before)
  end
end