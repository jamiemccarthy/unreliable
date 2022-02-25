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

Other ways you can order a relation ambiguously include:

* ORDER BY a column with values that differ only by [character case](https://dev.mysql.com/doc/refman/8.0/en/sorting-rows.html), 
* ORDER BY values that are identical within the [prefix length limit](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_max_sort_length) examined for sorting

`unreliable` correctly tests these because the random order is always appended.

# TODO

tests!

Is there a way to patch test blocks to run them multiple times with different orders (pk asc, desc, rand)? Worth digging into RSpec for this maybe.

# Development

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

The CI matrix gemfiles are built with `bundle exec appraisal install`. When it's necessary to add new minor versions of ActiveRecord or Ruby, update the Appraisals file and run `bundle exec appraisal update` as well as the install, and update the matrix in the ci.yml workflow.

# See also


