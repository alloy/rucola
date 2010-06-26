class Default < Thor
  desc "spec", "Run all specs"
  def spec
    specs = Dir.glob('spec/**/*_spec.rb')
    puts "Running specs: #{specs.join(', ')}"
    system "macruby -r #{specs.join(' -r ')} -e ''"
  end
end