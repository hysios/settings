# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'settings/version'

Gem::Specification.new do |spec|
  spec.name          = "settings"
  spec.version       = Settings::VERSION
  spec.authors       = ["Hysios Hu"]
  spec.email         = ["hysios@gmail.com"]
  spec.description   = %q{use YAML Settings in you Application}
  spec.summary       = %q{YAML Settings}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake"
end
