# frozen_string_literal: true

# The appraisal gem seems to be a convenient way to use this small config file to
# build the gemfiles/* for the GitHub CI matrix.
# Any `bundle update/install` should be accompanied by `bundle exec appraisal update/install`

appraise "activerecord-5.0" do
  gem "activerecord", "~> 5.0.0"
  gem "sqlite3", "~> 1.3.6"
end

appraise "activerecord-5.1" do
  gem "activerecord", "~> 5.1.0"
  gem "sqlite3", "~> 1.3.6"
end

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

# 7.1 isn't released yet; as of this writing this commit is the tip of the master branch.
# I'm not sure if there's a way to only pull in activerecord, so for this test purpose
# pulling in all of rails works fine, if a bit less efficient.

appraise "activerecord-7.1" do
  gem "rails", ref: "2497eb0d5daf4f9aebce692c5bfad3792fecc712"
end
