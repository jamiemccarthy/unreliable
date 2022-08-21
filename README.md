# Unreliable

![CI workflow](https://github.com/jamiemccarthy/unreliable/actions/workflows/ci.yml/badge.svg)
![Gem version](https://img.shields.io/gem/v/unreliable)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa)](code_of_conduct.md)

**`unreliable` forces your ActiveRecord tests not to rely on ambiguous ordering. This makes your app and its tests better.**

## Installation

Add `unreliable` to your `Gemfile`'s `test` group:

```ruby
# Gemfile

group :test do
  gem "unreliable", "~> 0.1"
end
```

The next time your test suite runs, it may emit new errors and failures. If so, great! See [#fixing-errors](Fixing errors), below.

## The problem

Here's an [open secret](#references): **relational databases do not guarantee the order results are returned in, without a well-chosen `ORDER BY` clause.**

Sometimes we think we specified an unambiguous order, but didn't. Often with timestamps. And your test suite will stay silent as long as your database just happens to return the same order.

If your Rails code relies on that accidental ordering, that's a bug in your app. Your tests are passing when they should be failing.

If ambiguous ordering is fine for your app's purposes, but your tests rely on a specific order, that's a bug in your tests. Your tests are failing, but only very rarely.

In both cases, `unreliable` exposes the problem by making your tests fail most of the time.

## Fixing the new failures

When `unreliable` turns up a new test failure, you fix it in one of two ways. Either relax your test so it stops relying on order, or tighten up your app to specify order precisely. (In my company's app, it was about 50/50.)

### Relax a test

Take a look at what your test is checking. If you're testing a method or an endpoint that returns a list whose order doesn't matter, you may have written it to expect the order that was returned the first time you ran it. This often happens with fixtures. You might:

* Make your test accept all correct answers. For example, sort an array in the method's response before comparing.

* Help your test suite focus on what you're testing. If your fixtures' "latest" element is random because they don't specify a timestamp, that may be a distraction that's not relevant to how your app works, so you could just assign them timestamps.

This makes your test suite more robust.

If your test suite is checking `.to_sql` against known-good SQL text, `unreliable` isn't helpful. It's easiest to use `Unreliable::Config.disable { ... }` to turn it off for a block.

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

As of August 2022, this is all released versions of both that are currently supported, plus several older releases.

`unreliable` depends only on ActiveRecord and Railties. If you have a non-Rails app that uses ActiveRecord, you can still use it.

## Implementation

**`unreliable` does exactly nothing outside of test environments. There is intentionally no way to enable `unreliable` in production, and there never will be.**

In a Rails test environment, `unreliable` patches ActiveRecord to always have a final `ORDER BY` clause that returns results in a random order.

With `unreliable` installed, every ActiveRecord relation invoked by the test suite will have any ambiguity replaced with randomness. Tests that rely on the ordering of two records will break half the time. Tests with three or more break most of the time.

`unreliable` patches `ActiveRecord::QueryMethods#build_arel`, the point where an Arel is converted for use, to append an order to the existing order chain. (The patch is applied after ActiveRecord loads, using `ActiveSupport.on_load`, the standard interface since Rails 4.0.) It works with MySQL, Postgres, and SQLite.

This means that the ORDER BY applies to not just SELECTs but e.g. delete_all and update_all. It also applies within subqueries.

The patch is only applied when `Rails.env.test?`, and that boolean is also checked on every invocation, just to make certain it has no effect in any other environment.

## Contributing

Thoughts and suggestions are welcome. Please read the code of conduct, then create an issue or pull request on GitHub. If you just have questions, go ahead and open an issue, I'm pretty friendly.

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

If you'd like to see `unreliable` in action on a small but real Rails app locally, you can do this:

1. Start with a 1-line Gemfile: `gem "rails", "~> x.y"`
2. `bundle install`, then:
3. `bundle exec rails new . --skip-javascript --skip-webpack-install --skip-sprockets --skip-turbolinks --skip-jbuilder --skip-spring`
4. Add to Gemfile test block: `gem "unreliable", path: "../unreliable"`
5. `bundle install` again
6. `bundle exec rails generate model post title:string body:text`
7. `RAILS_ENV=test bundle exec rails db:migrate`
8. `RAILS_ENV=test bundle exec rails c`
9. You should see "Loading test environment" and the Rails console prompt. Then to test:

```
2.7.6 :001 > puts Post.where(title: "abc").to_sql
   (0.7ms)  SELECT sqlite_version(*)
SELECT "posts".* FROM "posts" WHERE "posts"."title" = 'abc' ORDER BY RAND()
```

## Future development

When new minor versions of ActiveRecord or Ruby are released, I will update the Appraisals file and run `bundle exec appraisal update` as well as the install, and update the matrix in the ci.yml workflow. There will be a patch-level release for these changes, even if no `unreliable` code changes are required.

## Ordering trivia

The most common ambiguous ordering is an ORDER BY one column that is not unique, like a timestamp.

But there are other ways you can order a relation but still have your query be ambiguous:

* ORDER BY multiple columns, but with no subset which is unique
* ORDER BY a column with values that differ only by [character case](https://dev.mysql.com/doc/refman/8.0/en/sorting-rows.html)
* ORDER BY values that are identical within the [prefix length limit](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_max_sort_length) examined for sorting

`unreliable` correctly tests these because the random order is always appended.

## References

SQL standard ([SQL-92](https://web.archive.org/web/20220730144627/https://www.contrib.andrew.cmu.edu/~shadow/sql/sql1992.txt)):

> When the ordering of a cursor is partially determined by an _order by clause_, then the relative positions of two rows are determined only by the _order by clause_; if the two rows have equal values for the purpose of evaluating the _order by clause_, then their relative positions are implementation-dependent.

MySQL ([5.6](https://dev.mysql.com/doc/refman/5.6/en/limit-optimization.html), [5.7](https://dev.mysql.com/doc/refman/5.7/en/limit-optimization.html), [8.0](https://dev.mysql.com/doc/refman/8.0/en/limit-optimization.html)):

> If multiple rows have identical values in the `ORDER BY` columns, the server is free to return those rows in any order, and may do so differently depending on the overall execution plan. In other words, the sort order of those rows is nondeterministic with respect to the nonordered columns.

Postgres ([12](https://www.postgresql.org/docs/12/sql-select.html#SQL-ORDERBY), [13](https://www.postgresql.org/docs/13/sql-select.html#SQL-ORDERBY), [14](https://www.postgresql.org/docs/14/sql-select.html#SQL-ORDERBY)):

> If two rows are equal according to the leftmost expression, they are compared according to the next expression and so on. If they are equal according to all specified expressions, they are returned in an implementation-dependent order.

SQLite ([3.39](https://www.sqlite.org/lang_select.html#the_order_by_clause):

> The order in which two rows for which all ORDER BY expressions evaluate to equal values are returned is undefined.

## See also

[chaotic_order](https://rubygems.org/gems/chaotic_order)
