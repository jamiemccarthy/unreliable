# frozen_string_literal: true

require "./lib/unreliable/version"

Gem::Specification.new do |s|
  s.name = "unreliable"
  s.version = Unreliable::VERSION
  s.license = "MIT"
  s.summary = "Randomize relation final order for tests"
  s.description = <<~EODESC
    Unreliable helps uncover bugs in Rails apps that rely on ambiguous database ordering.
    With it installed, a test suite is less likely to accidentally succeed.
  EODESC
  s.author = "James McCarthy"
  s.email = "jamie@mccarthy.vg"
  s.homepage = "https://github.com/jamiemccarthy/unreliable"
  s.metadata = {
    "changelog_uri" => "https://github.com/jamiemccarthy/unreliable/blob/main/CHANGELOG.md",
    "rubygems_mfa_required" => "true"
  }
  s.files = Dir["lib/**/*"] +
    Dir["gemfiles/*"] +
    Dir["spec/**"] + [
      "Appraisals",
      "CHANGELOG.md",
      "CODE_OF_CONDUCT.md",
      "Gemfile",
      "LICENSE",
      "Rakefile",
      "README.md"
    ]

  s.required_ruby_version = ">= 2.6"

  s.add_dependency "activerecord", ">= 5.0", "< 8.0"
  s.add_dependency "railties", ">= 5.0", "< 8.0"

  s.add_development_dependency "appraisal", "~> 2.4"
  s.add_development_dependency "bundler", "~> 2.1"
  s.add_development_dependency "combustion", "~> 1.3"
  s.add_development_dependency "rake", "~> 13.0"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "sqlite3", "~> 1.4"
  s.add_development_dependency "standard", "~> 1.11"
end
