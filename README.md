# unreliable

![CI workflow](https://github.com/jamiemccarthy/unreliable/actions/workflows/ci.yml/badge.svg)

In a Rails test environment, Unreliable patches ActiveRecord to have a final ORDER BY clause that returns results in a random order.

If the specified order for any relation is ambiguous, including if no order at all is specified, relational databases do not define the resulting order in which rows are returned. This is true for Postgres, MySQL, and SQLite.

However, in practice databases often happen to return the same order in most cases.

Authors of tests will often rely on this unreliable ordering, which leads to tests passing accidentally.

With Unreliable installed, every ActiveRecord relation invoked by the test suite will have a final ORDER BY clause that replaces the ambiguity with randomness. Thus tests that rely on the ordering of at least two records will typically break at least half the time.

It does nothing outside of test environments, and there is intentionally no way to enable Unreliable in any other environment.

# Implementation

Unreliable patches `ActiveRecord::QueryMethods#build_arel`, the point where an Arel is converted for use, to append an order to the existing order chain. (The patch is applied after ActiveRecord loads, using `ActiveSupport.on_load`, the standard interface since Rails 4.0.)

This means that the ORDER BY applies to not just SELECTs but e.g. delete_all and update_all. It also applies within subqueries.

By always appending the random order, we ensure unreliable ordering for relations that have no order at all, and also for relations with an ambiguous order. For example, ordering by a non-unique column, or a combination of multiple columns which together are non-unique.

The patch is only applied when `Rails.env.test?`, and that boolean is also checked on every invocation to make certain it has no effect in any other environment.

# Fun trivia

There are other ways you can order a relation but still have your query be ambiguous!

* ORDER BY a column with values that differ only by [character case](https://dev.mysql.com/doc/refman/8.0/en/sorting-rows.html), 
* ORDER BY values that are identical within the [prefix length limit](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_max_sort_length) examined for sorting

`unreliable` correctly tests these because the random order is always appended.

# Testing

To test locally, against the different versions of ActiveRecord, use Ruby 2.7, the only version currently compatible with all the ActiveRecord versions supported. Install the required gems with:

```
gem install bundler
bundle install
bundle exec appraisal install
```

Then you can run the tests with:

```
bundle exec appraisal rake
```

Appraisal ensures the tests run against every compatible minor version of ActiveRecord.

The GitHub CI workflow in `.github/` ensures those tests are also run against against every compatible minor version of Ruby.

Testing against ActiveRecord is done with [Combustion](https://github.com/pat/combustion), which stands up a local single-table SQLite database and an ActiveRecord-based model for it. This gives us more reliable coverage than mocking unit tests within ActiveRecord itself.

Some initial testing was done against a small but real Rails app locally, which looked like this (I mention this for historical interest only):

```
Start with 1-line Gemfile `gem "rails", "~> x.y"`, bundle install, then

$ bundle exec rails new . --skip-javascript --skip-webpack-install --skip-sprockets --skip-turbolinks --skip-jbuilder --skip-spring

Add to Gemfile test block: gem "unreliable", path: "../unreliable", bundle install again

$ bundle exec rails generate model post title:string body:text
$ RAILS_ENV=test bundle exec rails db:migrate
$ RAILS_ENV=test bundle exec rails c
Loading test environment (Rails 7.0.1)
3.0.1 :001 > puts Post.where(title: "abc").to_sql
   (0.7ms)  SELECT sqlite_version(*)
SELECT "posts".* FROM "posts" WHERE "posts"."title" = 'abc' ORDER BY RAND()
```

# Development

When it's necessary to add new minor versions of ActiveRecord or Ruby, update the Appraisals file and run `bundle exec appraisal update` as well as the install, and update the matrix in the ci.yml workflow.

# Contributing

Thoughts and suggestions are welcome. Please read the code of conduct, then create an issue or pull request on GitHub.

Future work I'd like to see done includes:

* Moving to containerized testing, so the test suite can cover MySQL and Postgres.

* Addressing the deprecation warnings in the test suite for ActiveRecord 5.x. There are two: SQLite 1.3 warning of incompatibility with Ruby 3.2 (which is irrelevant since Rails 5 won't run on Ruby 3.2 and Rails 6 requires SQLite 1.4). And: `DEPRECATION WARNING: Leaving ActiveRecord::ConnectionAdapters::SQLite3Adapter.represent_boolean_as_integer set to false is deprecated.`

* I'd love to see if there is a way to patch test blocks to run them multiple times with different orders (pk asc, desc, rand). It's hard to see a clean way to do this with a BEGIN/ROLLBACK but maybe it's possible. I doubt there is one simple bottleneck for this in RSpec but I haven't looked into it. By nature this gem makes testing nondeterministic, and if there's a way to actually run queries multiple ways, that would be slower but more comprehensive. On the other hand, if a test suite only defines one fixture item, neither this improvement nor the current state of this gem can catch ordering issues.

# See also

[chaotic_order](https://rubygems.org/gems/chaotic_order)
