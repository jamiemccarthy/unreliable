# frozen_string_literal: true

require "./lib/unreliable/version"

Gem::Specification.new do |s|
  s.name = "unreliable"
  s.version = Unreliable::VERSION
  s.license = "MIT"

  s.author = "James McCarthy"
  s.description = s.summary = "Randomize relation final order for tests"
  s.email = ["jamie@mccarthy.vg"]
  s.files = Dir.glob("lib/**/*") + [
    "LICENSE",
    "README.md",
    "CHANGELOG.md",
    "Gemfile"
  ]
  s.homepage = "https://github.com/jamiemccarthy/unreliable"

  s.required_ruby_version = ">= 2.5"

  s.add_dependency "activerecord", ">= 5.0"

  s.add_development_dependency "appraisal", "~> 2.4"
  s.add_development_dependency "bundler", "~> 2.1"
  s.add_development_dependency "minitest", "~> 5.15"
  s.add_development_dependency "rake", "~> 13.0"
  s.add_development_dependency "rubocop", "~> 1.24"
  s.add_development_dependency "simplecov", "~> 0.21"

  s.metadata = {
    "rubygems_mfa_required" => "true"
  }
end
