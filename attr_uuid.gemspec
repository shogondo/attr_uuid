# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'attr_uuid/version'

Gem::Specification.new do |gem|
  gem.name          = "attr_uuid"
  gem.version       = AttrUuid::VERSION
  gem.authors       = ["Shou Takenaka"]
  gem.email         = ["sasaminn@gmail.com"]
  gem.description   = %q{This gem makes binary uuid attribute easy to use}
  gem.summary       = %q{Easy to use binay uuid attribute}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "activerecord"
  gem.add_dependency "uuidtools"

  gem.add_development_dependency "mysql2"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "with_model"
end
