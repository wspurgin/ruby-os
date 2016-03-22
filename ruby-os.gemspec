lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby-os/version'

Gem::Specification.new do |gem|
  gem.name          = 'ruby-os'
  gem.version       = RubyOS::VERSION
  gem.date          = '2016-03-21'
  gem.summary       = "An Operating System in Ruby"
  gem.description   = "A simple set of operating system components written in Ruby"
  gem.authors       = ["Will Spurgin"]
  gem.email         = "will.spurgin@gmail.com"
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.homepage      = "https://github.com/wspurgin/ruby-os"
  gem.license       = 'MIT'

  gem.add_development_dependency 'rake', '>= 10.5.0'
  gem.add_development_dependency 'rspec', '>= 3.3.0'
end
