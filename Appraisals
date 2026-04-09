# frozen_string_literal: true

# The appraisal gem uses this file to define the gemfiles/* used by the CI matrix.
#
# Dev dependencies live in the Gemfile (not the gemspec). Appraisal reads the root
# Gemfile when generating gemfiles, so those deps appear in every generated gemfile
# automatically. The sqlite3 pin in activerecord-5.2 overrides the root Gemfile version.
# activerecord-8.0 and 8.1 also override sqlite3 because AR 8.0 requires >= 2.1 at runtime.
#
# When editing this file, update gemfiles/*.gemfile manually (appraisal generate bakes
# into the Docker image and can't write back to the host), then run `bundle lock` for
# each affected lockfile.

appraise "activerecord-5.2" do
  gem "activerecord", "~> 5.2.0"
  gem "sqlite3", "~> 1.3.6"
  gem "activerecord-sqlserver-adapter"
  gem "tiny_tds"
end

appraise "activerecord-6.0" do
  gem "activerecord", "~> 6.0.0"
  gem "activerecord-trilogy-adapter"
  gem "trilogy"
  gem "activerecord-sqlserver-adapter"
  gem "tiny_tds"
  # Gems removed from Ruby's default/bundled set that ActiveSupport 6.x requires:
  gem "mutex_m"   # removed in Ruby 3.4
  gem "base64"    # removed in Ruby 3.4
  gem "benchmark" # removed in Ruby 4.0
  gem "logger"    # removed in Ruby 4.0
end

appraise "activerecord-6.1" do
  gem "activerecord", "~> 6.1.0"
  gem "activerecord-trilogy-adapter"
  gem "trilogy"
  gem "activerecord-sqlserver-adapter"
  gem "tiny_tds"
  # Gems removed from Ruby's default/bundled set that ActiveSupport 6.x requires:
  gem "mutex_m"   # removed in Ruby 3.4
  gem "base64"    # removed in Ruby 3.4
  gem "benchmark" # removed in Ruby 4.0
  gem "logger"    # removed in Ruby 4.0
end

appraise "activerecord-7.0" do
  gem "activerecord", "~> 7.0.0"
  gem "activerecord-trilogy-adapter"
  gem "trilogy"
  gem "activerecord-sqlserver-adapter"
  gem "tiny_tds"
end

appraise "activerecord-7.1" do
  gem "activerecord", "~> 7.1.0"
  gem "trilogy"
  gem "activerecord-sqlserver-adapter"
  gem "tiny_tds"
end

appraise "activerecord-7.2" do
  gem "activerecord", "~> 7.2.0"
  gem "trilogy"
  gem "activerecord-sqlserver-adapter"
  gem "tiny_tds"
end

appraise "activerecord-8.0" do
  gem "activerecord", "~> 8.0.0"
  gem "trilogy"
  gem "activerecord-sqlserver-adapter"
  gem "tiny_tds"
  gem "sqlite3", "~> 2.1" # AR 8.0 requires sqlite3 >= 2.1 at runtime
end

appraise "activerecord-8.1" do
  gem "activerecord", "~> 8.1.0"
  gem "trilogy"
  gem "activerecord-sqlserver-adapter"
  gem "tiny_tds"
end
