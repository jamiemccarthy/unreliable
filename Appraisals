# frozen_string_literal: true

# The appraisal gem seems to be a convenient way to use this small config file to
# build the gemfiles/* for the GitHub CI matrix.
# Any `bundle update/install` should be accompanied by `bundle exec appraisal update/install`
#
# Dev dependencies live in the Gemfile (not the gemspec). Appraisal reads the root
# Gemfile when generating gemfiles, so those deps appear in every generated gemfile
# automatically. The sqlite3 pin in activerecord-5.2 overrides the root Gemfile version.

appraise "activerecord-5.2" do
  gem "activerecord", "~> 5.2.0"
  gem "sqlite3", "~> 1.3.6"
end

appraise "activerecord-6.0" do
  gem "activerecord", "~> 6.0.0"
end

appraise "activerecord-6.1" do
  gem "activerecord", "~> 6.1.0"
end

appraise "activerecord-7.0" do
  gem "activerecord", "~> 7.0.0"
end

appraise "activerecord-7.1" do
  gem "activerecord", "~> 7.1.0"
end

appraise "activerecord-7.2" do
  gem "activerecord", "~> 7.2.0"
end

appraise "activerecord-8.0" do
  gem "activerecord", "~> 8.0.0"
end

appraise "activerecord-8.1" do
  gem "activerecord", "~> 8.1.0"
end
