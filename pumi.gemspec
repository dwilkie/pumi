lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pumi/version"

Gem::Specification.new do |spec|
  spec.name          = "pumi"
  spec.version       = Pumi::VERSION
  spec.authors       = ["David Wilkie"]
  spec.email         = ["dwilkie@gmail.com"]
  spec.summary       = "Villages (ភូមិ), Communes (ឃុំ - សង្កាត់), Districts (ស្រុក - ខណ្ឌ) and Provinces (ខេត្ត) in Cambodia"
  spec.homepage      = "https://github.com/dwilkie/pumi"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "coffee-rails"
  spec.add_development_dependency "jquery-rails"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "puma"
  spec.add_development_dependency "rails", ">= 5.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-rails", "~> 3.0"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "selenium-webdriver"
  spec.add_development_dependency "webdrivers"
end
