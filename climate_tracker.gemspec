# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'climate_tracker/version'

Gem::Specification.new do |spec|
  spec.name          = "climate_tracker"
  spec.version       = ClimateTracker::VERSION
  spec.authors       = ["Will Lynch"]
  spec.email         = ["will.lynch91@gmail.com"]

  spec.summary       = %q{Access average monthly temperatures through data retrieved from the NOAA Cliamte API}
  spec.description   = %q{Allows anyone to view the average monthly temperature for any state in the US between 1831 and 2015.  It also allows users to compare the averages across date ranges and display changes over time.}
  spec.homepage      = "https://github.com/lynch16/climate-tracker-cli-gem"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
