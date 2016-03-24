# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'app_logger/version'

Gem::Specification.new do |spec|
  spec.name          = "app_logger"
  spec.version       = AppLogger::VERSION
  spec.authors       = ["arukoh"]
  spec.email         = ["arukoh10@gmail.com"]

  spec.summary       = %q{Rack middleware to output like access log.}
  spec.description   = %q{Rack middleware to output like access log.}
  spec.homepage      = "https://github.com/arukoh/app_logger"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "rack-test", "~> 0.6"

  spec.add_dependency "rack", "~> 1.6"
  spec.add_dependency "activesupport", "~> 4"
end
