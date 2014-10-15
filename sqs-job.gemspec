# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sqs/job/version'

Gem::Specification.new do |spec|
  spec.name          = "sqs-job"
  spec.version       = SQS::Job::VERSION
  spec.authors       = ["Jon Mason", "Kevin Gilpin"]
  spec.email         = ["jonathan.j.mason@gmail.com", "kgilpin@gmail.com"]
  spec.summary       = %q{Simple job processing library which uses SQS.}
  spec.homepage      = "https://github.com/conjurinc/sqs-job"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "validatable"
  spec.add_development_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
end
