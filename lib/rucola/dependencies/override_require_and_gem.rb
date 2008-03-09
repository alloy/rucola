# These monkey patches are used in a app if it has rucola bundled

# make Gem work
unless defined? Gem
  module Gem
    class LoadError < StandardError; end
  end
end

module Rucola
  class Dependencies
    def self.override_require_and_gem!
      Kernel.module_eval do
        alias_method :__require_before_rucola_standalone_app, :require
        def require(name)
          return if name == 'rubygems' # atm we don't want to allow rubygems
          # check if there's an exception for this requirement and load it, otherwise load the original
          exception = Rucola::Dependencies.instance.exceptions[name] if Rucola::Dependencies.respond_to?(:instance) # check if everything is done loading
          __require_before_rucola_standalone_app(exception || name)
        end

        def gem(name, version)
          #puts "Gem required: #{name}"
          require(name)
        end
      end
    end
  end
end