# frozen_string_literal: true

require_relative "lib/unreliable/version"

Gem::Specification.new do |s|
  s.name = "unreliable"
  s.version = Unreliable::VERSION
  s.license = "MIT"
  s.summary = "For ActiveRecord tests, surface ambiguous-ordering bugs"
  s.description = <<~EODESC
    Unreliable helps uncover bugs in Rails apps that rely on ambiguous database ordering.
    Installing it makes both your app and your test suite more robust.
  EODESC
  s.author = "James McCarthy"
  s.email = "jamie@mccarthy.vg"
  s.homepage = "https://github.com/jamiemccarthy/unreliable"
  s.metadata = {
    "changelog_uri" => "https://github.com/jamiemccarthy/unreliable/blob/main/CHANGELOG.md",
    "rubygems_mfa_required" => "true"
  }
  s.files = Dir["lib/**/*"] +
    Dir["spec/**"] + [
      "CHANGELOG.md",
      "CODE_OF_CONDUCT.md",
      "Gemfile",
      "LICENSE",
      "Rakefile",
      "README.md"
    ]

  s.required_ruby_version = ">= 2.6"

  s.add_dependency "activerecord", ">= 5.2", "< 8.0"
  s.add_dependency "railties", ">= 5.2", "< 8.0"

  s.add_development_dependency "appraisal", "~> 2.4"
  s.add_development_dependency "bundler", "~> 2.1"
  s.add_development_dependency "combustion", "~> 1.3"
  s.add_development_dependency "mysql2", "~> 0.5"
  s.add_development_dependency "pg", "~> 1.5"
  s.add_development_dependency "rake", "~> 13.0"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "sqlite3", ((RUBY_VERSION >= "3.2") ? "~> 1.6.9" : "~> 1.5.4")
  s.add_development_dependency "standard", "~> 1.17"
  s.add_development_dependency "yamllint", "~> 0.0.9"
end
