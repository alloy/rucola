# To install all gems, including Thor: $ macruby Thorfile
unless defined?(Thor)
  class Thor
    def self.desc(*); end
    def system(cmd); puts cmd; super; end
  end
  END { Default.new.install_gems }
end

class Default < Thor
  desc "install_gems", "Install Gem dependencies"
  def install_gems
    system "macgem install thor"
    system "macgem install activesupport --pre"
  end
  
  desc "spec", "Run all specs"
  def spec
    specs = Dir.glob('spec/**/*_spec.rb')
    puts "Running specs: #{specs.join(', ')}"
    system "macruby -r #{specs.join(' -r ')} -e ''"
  end
end