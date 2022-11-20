# Unreliable

![CI workflow](https://github.com/jamiemccarthy/unreliable/actions/workflows/ci.yml/badge.svg)
![Gem version](https://img.shields.io/gem/v/unreliable)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa)](CODE_OF_CONDUCT.md)

**The `unreliable` gem forces your ActiveRecord tests not to rely on ambiguous ordering. This makes your app and its tests more robust.**

## Installation

Add `unreliable` to your `Gemfile`'s `test` group:

```ruby
# Gemfile

group :test do
  gem "unreliable", "~> 0.1"
end
```

The next time your test suite runs, it may emit new errors and failures. If so, great!

## The problem with orders

Here's an [open secret](#references): **relational databases do not guarantee the order results are returned in, without a thorough `ORDER BY` clause.**

If all your ActiveRecord ordering is already unambiguous, congratulations! `unreliable` will have no effect.

But sometimes we think we specified an unambiguous order, but didn't. Maybe we ordered on timestamps, which are usually unique but sometimes not. And the test suite will stay silent as long as our database just happens to return the same order.

If ambiguous ordering is fine for your app's purposes, but your tests rely on a specific order, that's a bug in your tests. Your tests are incorrectly failing -- rarely -- which can be confusing and annoying.

Or, if your Rails code relies on that accidental ordering, that's a bug in your app. Your tests are passing when they should be failing.

In both cases, `unreliable` exposes the problem by making those tests fail most of the time.

## Fixing the new failures

When `unreliable` turns up a new test failure, you fix it in one of two ways. Either relax your test so it stops relying on order, or tighten up your app to specify order rigorously. (In my company's app, it was about 50/50.)

### Relax a test

Take a look at what your test is checking. If you're testing a method or an endpoint that returns a list whose order doesn't matter, you may have written it to expect the order that was returned the first time you ran it. This often happens with fixtures. You might:

* Make your test accept all correct answers. For example, sort an array in the method's response before comparing.

* Help your test suite focus on what you're testing. If your fixtures' "latest" element could change because they don't specify a timestamp, that might be a distraction that's not relevant to how your app works, so you could assign timestamps to the fixtures.

This makes your test suite more robust.

If your test suite is checking generated `.to_sql` against known-good SQL text, `unreliable` isn't helpful. It's easiest to use `Unreliable::Config.disable { ... }` to turn it off for a block.

### Tighten the app

If your app should be returning results in a particular order, and now with `unreliable` it sometimes does not, your test is correct and your app is wrong. Specify order rigorously in your app.

Maybe you're testing `Book.reverse_chron.first`, and you've defined that ordering this way:

```
class Book
  scope :reverse_chron, -> { order(year_published: :desc) }
end
```

When you meant to define it unambiguously:

```
  scope :reverse_chron, -> { order(year_published: :desc, title: :desc) }
```

Or, if `title` is not unique:

```
  scope :reverse_chron, -> { order(year_published: :desc, title: :desc, id: :desc) }
```

The problem in this example is easy to see because many books are published each year. But this error can occur at any time granularity.

## Requirements

`unreliable` is tested to support Ruby 2.6 through 3.1, and Rails 5.0 through 7.0.

As of November 2022, this is all released versions of both that are currently supported, plus several older releases.

`unreliable` depends only on ActiveRecord and Railties. If you have a non-Rails app that uses ActiveRecord, you can still use it.

## Implementation

`unreliable` does exactly nothing outside of test environments. There is intentionally no way to enable `unreliable` in production, and there never will be.

In a Rails test environment, `unreliable` patches ActiveRecord to append a final `ORDER BY` clause, when necessary, that returns results in a random order.

Because it's appended, the existing ordering is not affected unless it is ambiguous.

With `unreliable` installed, every ActiveRecord relation invoked by the test suite will have any ambiguity replaced with randomness. Tests that rely on the ordering of two records will break half the time. Tests with three or more break most of the time.

`unreliable` patches `ActiveRecord::QueryMethods#build_arel`, the point where an Arel is converted for use, to append an order to the existing order chain. (The patch is applied after ActiveRecord loads, using `ActiveSupport.on_load`, the standard interface since Rails 4.0.) It works with MySQL, Postgres, and SQLite.

This means that the `ORDER BY` applies to not just `SELECT` but e.g. `delete_all` and `update_all`. It also applies within subqueries.

The patch is only applied when `Rails.env.test?`, and that boolean is also checked on every invocation, just to make certain it has no effect in any other environment.

## Contributing

Thoughts and suggestions are welcome. Please read the code of conduct, then create an issue or pull request on GitHub. If you just have questions, go ahead and open an issue, I'm pretty friendly.

### Run the gem's tests

To test locally, against the different versions of ActiveRecord, use Ruby 2.7, the only version currently compatible with all the ActiveRecord versions supported. Install the required gems with:

```
gem install bundler
bundle install
bundle exec appraisal install
```

Run `unreliable`'s linter with:

```
bundle exec standardrb
```

Then you can run `unreliable`'s tests with:

```
bundle exec appraisal rake
```

Appraisal ensures the tests run against every compatible minor version of ActiveRecord.

The GitHub CI workflow in `.github/` ensures those tests are also run against against every compatible minor version of Ruby. Your PR won't trigger my GitHub project's workflow, but you're welcome to run your own, or ask me to run mine manually.

Testing against ActiveRecord is done with [Combustion](https://github.com/pat/combustion), which stands up a local single-table SQLite database and an ActiveRecord-based model for it. This gives more reliable coverage than mocking unit tests within ActiveRecord itself.

### Experiment

If you'd like to see `unreliable` in action on a small but real Rails app locally, you can do this:

1. In a directory next to your `unreliable` working directory, create a `.ruby-version` of `2.7.6` and a 2-line `Gemfile`: `source "https://rubygems.org"`, `gem "rails", "~> 7.0"`
2. `bundle install && bundle exec rails new . --force`
3. `echo 'gem "unreliable", path: "../unreliable"' >> Gemfile`
4. `bundle install && bundle exec rails generate model post title:string body:text`
5. `RAILS_ENV=test bundle exec rails db:migrate`
6. `RAILS_ENV=test bundle exec rails c`
7. You should see SQLite's `ORDER BY RANDOM()` in ActiveRecord queries:

```
irb(main):001:0> Post.where(title: "abc")
   (2.1ms)  SELECT sqlite_version(*)
  Post Load (0.3ms)  SELECT "posts".* FROM "posts" WHERE "posts"."title" = ? ORDER BY RANDOM()  [["title", "abc"]]
=> []
irb(main):002:0> Post.limit(5).delete_all
  Post Delete All (0.2ms)  DELETE FROM "posts" WHERE "posts"."id" IN (SELECT "posts"."id" FROM "posts" ORDER BY RANDOM() LIMIT ?)  [["LIMIT", 5]]
=> 0
```

## Ordering trivia

The most common ambiguous ordering is an ORDER BY one column that is not unique, like a timestamp.

But there are other ways you can order a relation but still have your query be ambiguous:

* ORDER BY multiple columns, but with no subset which is unique
* ORDER BY a column with values that differ only by [character case](https://dev.mysql.com/doc/refman/8.0/en/sorting-rows.html)
* ORDER BY values that are identical within the [prefix length limit](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_max_sort_length) examined for sorting

`unreliable` ensures correct testing because it appends a random order to each of these cases.

## References

SQL standard ([SQL-92](https://web.archive.org/web/20220730144627/https://www.contrib.andrew.cmu.edu/~shadow/sql/sql1992.txt)):

> When the ordering of a cursor is partially determined by an _order by clause_, then the relative positions of two rows are determined only by the _order by clause_; if the two rows have equal values for the purpose of evaluating the _order by clause_, then their relative positions are implementation-dependent.

MySQL ([5.6](https://dev.mysql.com/doc/refman/5.6/en/limit-optimization.html), [5.7](https://dev.mysql.com/doc/refman/5.7/en/limit-optimization.html), [8.0](https://dev.mysql.com/doc/refman/8.0/en/limit-optimization.html)):

> If multiple rows have identical values in the `ORDER BY` columns, the server is free to return those rows in any order, and may do so differently depending on the overall execution plan. In other words, the sort order of those rows is nondeterministic with respect to the nonordered columns.

Postgres ([12](https://www.postgresql.org/docs/12/sql-select.html#SQL-ORDERBY), [13](https://www.postgresql.org/docs/13/sql-select.html#SQL-ORDERBY), [14](https://www.postgresql.org/docs/14/sql-select.html#SQL-ORDERBY)):

> If two rows are equal according to the leftmost expression, they are compared according to the next expression and so on. If they are equal according to all specified expressions, they are returned in an implementation-dependent order.

SQLite ([3.39](https://www.sqlite.org/lang_select.html#the_order_by_clause)):

> The order in which two rows for which all ORDER BY expressions evaluate to equal values are returned is undefined.

## See also

[chaotic_order](https://rubygems.org/gems/chaotic_order)
