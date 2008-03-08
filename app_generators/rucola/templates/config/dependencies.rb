Rucola::Dependencies.run do
  # Specify dependencies of your application.
  # Eg:
  #
  #   dependency 'net/http'
  #
  # Or if it's a gem you can also specify a specific version.
  # (See the gem documentation about the possibilities).
  # Eg:
  #
  #   dependency 'daemons', '1.0.7'
  #
  # Sometimes there will be some libraries that just can't be resolved. For these you can add exceptions:
  # Eg:
  #
  #   # when "require 'xml-simple'" is called it will be replaced with "require 'xmlsimple'"
  #   exception 'xml-simple', 'xmlsimple'
  #
  # Or you can pass these in a block for grouping,
  # but note that it's exaclty the same as defining the exception outside of the block.
  # Eg:
  #
  #   dependency 'activesupport' do
  #     # there's a problem with the gem being named 'xml-simple',
  #     # but the file's called 'xmlsimple'.
  #     exception 'xml-simple', 'xmlsimple'
  #   end
  
  # We'll assume that you'll want to bundle rucola by default.
  dependency 'rucola'
end