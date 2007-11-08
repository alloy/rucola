require 'autotest'

class Autotest::Rucola < Autotest

  def initialize # :nodoc:
    super
    @exceptions = /^\.\/(?:script|vendor\/rubycocoa)/
  
    @test_mappings = {
      %r%^app/models/(.*)\.rb$% => proc { |_, m|
        ["test/models/test_#{m[1]}.rb"]
      },
      %r%^app/controllers/(.*)\.rb$% => proc { |_, m|
        ["test/controllers/test_#{m[1]}.rb"]
      },
      %r%^test/.*\.rb$% => proc { |filename, _|
        filename 
      }
    }
  end

  # Given the string filename as the path, determine
  # the corresponding tests for it, in an array.
  def tests_for_file(filename)
    super.select { |f| @files.has_key? f }
  end

  # Convert the pathname s to the name of class.
  def path_to_classname(s)
    sep = File::SEPARATOR
    f = s.sub(/^test#{sep}((models|controllers)#{sep})?/, '').sub(/\.rb$/, '').split(sep)
    f = f.map { |path| path.split(/_/).map { |seg| seg.capitalize }.join }
    f = f.map { |path| path.sub(/^Test/, '') }
    f.join('::')
  end
end
