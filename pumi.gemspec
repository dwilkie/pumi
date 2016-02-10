# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pumi/version'

Gem::Specification.new do |spec|
  spec.name          = "pumi"
  spec.version       = Pumi::VERSION
  spec.authors       = ["David Wilkie"]
  spec.email         = ["dwilkie@gmail.com"]

  spec.summary       = %q{Villages (ភូមិ), Communes (ឃុំ - សង្កាត់), Districts (ស្រុក - ខណ្ឌ) and Provinces (ខេត្ត) in Cambodia}
  spec.homepage      = "https://github.com/dwilkie/pumi"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-rails", "~> 3.0"
  spec.add_development_dependency "rails", "~> 4.2.5.1"
  spec.add_development_dependency "coffee-rails"
  spec.add_development_dependency "jquery-rails"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "selenium-webdriver"
  spec.add_development_dependency "launchy"
  spec.add_development_dependency "pry"
end
