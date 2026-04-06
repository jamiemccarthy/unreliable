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

  s.add_dependency "activerecord", ">= 5.2", "< 9.0"
  s.add_dependency "railties", ">= 5.2", "< 9.0"
end
