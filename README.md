# Unreliable

![CI workflow](https://github.com/jamiemccarthy/unreliable/actions/workflows/ci.yml/badge.svg)
![Gem version](https://img.shields.io/gem/v/unreliable)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa)](code_of_conduct.md)

**Unreliable makes your ActiveRecord scopes and test suite better, by forcing your tests to not rely on ambiguous ordering.**

## Installation

Add `unreliable` to your `Gemfile`'s `test` group:

```ruby
# Gemfile

group :test do
  gem "unreliable", "~> 0.1"
end
```

Then `bundle install` and run your test suite repeatedly, maybe 6-8 times, looking for new failures.

## The problem

Here's an open secret: relational databases do not guarantee the order results are returned in, without a well-chosen ORDER BY clause.

Choosing a good ORDER is harder than it seems. And you can get it wrong silently. Your test suite won't help you if your database just happens to return the same order almost all the time. Which they usually do.

If your Rails code relies on that accidental ordering, that's a bug in your app. Or sometimes ambiguous order is fine for your app's purposes, but your tests rely on it. Either way, your tests are passing when they should be failing.

## The test

In a Rails test environment, Unreliable patches ActiveRecord to always have a final ORDER BY clause that returns results in a random order.

With Unreliable installed, every ActiveRecord relation invoked by the test suite will have any ambiguity replaced with randomness. Tests that rely on the ordering of at least two records will typically break at least half the time. Tests with three or more break most of the time.

If you install Unreliable and your test suite starts failing, but only sometimes, that tells you to check your app's relations and scopes, and check your tests.

Even your relations with an order may have an ambiguous order. See "Ordering trivia" below.

## The fixes

When Unreliable turns up a new test failure, it's for one of two reasons. Either your test needs to stop relying on order, or your app needs to specify order better.

### Incorrect test

Take a look at what you're testing. If you're testing a method or an endpoint that returns a list whose order doesn't matter and isn't documented, you may have written it to expect the order that was returned the first time you ran it. This often happens with fixtures.

Make your test accept all correct answers. For example, sort the method's response before comparing.

### Incorrect app

If your app should be returning results in a particular order, and now with Unreliable it sometimes does not, your test is correct and your app is wrong. Specify order rigorously in your app.

Maybe you've defined an ordering this way:

```
  class Book
    scope :reverse_chron, -> { order(year_published: :desc) }
  end
```

When you meant to define it unambiguously:

```
  class Book
    scope :reverse_chron, -> { order(year_published: :desc, title: :desc) }
  end
```

Or, if `title` is not unique:

```
  class Book
    scope :reverse_chron, -> { order(year_published: :desc, title: :desc, id: :desc) }
  end
```

This example is obviously wrong because many books are published each year, but this error can occur at any time granularity.

## Requirements

Unreliable is tested to support Ruby 2.6 through 3.1, and Rails 5.0 through 7.0.

As of April 2022, this is all released versions of both that are currently supported, plus several older releases.

Unreliable depends only on ActiveRecord and Railties. If you have a non-Rails app that uses ActiveRecord, you can still use it.

## Implementation

**Unreliable does exactly nothing outside of test environments. There is intentionally no way to enable Unreliable in production or any other environment, and there never will be.**

Unreliable patches `ActiveRecord::QueryMethods#build_arel`, the point where an Arel is converted for use, to append an order to the existing order chain. (The patch is applied after ActiveRecord loads, using `ActiveSupport.on_load`, the standard interface since Rails 4.0.)

This means that the ORDER BY applies to not just SELECTs but e.g. delete_all and update_all. It also applies within subqueries.

By appending the random order to every single query, we ensure unreliable ordering for relations that have no order at all, and also for relations with an ambiguous order.

The patch is only applied when `Rails.env.test?`, and that boolean is also checked on every invocation to make certain it has no effect in any other environment.

`Unreliable::Config.disable do ... end` will turn it off for a block.

## Ordering trivia

The most common ambiguous ordering is an ORDER BY one column that is not unique, perhaps a timestamp.

But there are other ways you can order a relation but still have your query be ambiguous:

* ORDER BY multiple columns, no subset of which is unique
* ORDER BY a column with values that differ only by [character case](https://dev.mysql.com/doc/refman/8.0/en/sorting-rows.html)
* ORDER BY values that are identical within the [prefix length limit](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_max_sort_length) examined for sorting

Unreliable correctly tests these because the random order is always appended.

## Contributing

Thoughts and suggestions are welcome. Please read the code of conduct, then create an issue or pull request on GitHub. If you just have questions, go ahead and open an issue, I'm pretty friendly.

To test locally, against the different versions of ActiveRecord, use Ruby 2.7, the only version currently compatible with all the ActiveRecord versions supported. Install the required gems with:

```
gem install bundler
bundle install
bundle exec appraisal install
```

Run Unreliable's linter with:

```
bundle exec standardrb
```

Then you can run Unreliable's tests with:

```
bundle exec appraisal rake
```

Appraisal ensures the tests run against every compatible minor version of ActiveRecord.

The GitHub CI workflow in `.github/` ensures those tests are also run against against every compatible minor version of Ruby. Your PR won't trigger my GitHub project's workflow, but you're welcome to run your own, or ask me to run mine manually.

Testing against ActiveRecord is done with [Combustion](https://github.com/pat/combustion), which stands up a local single-table SQLite database and an ActiveRecord-based model for it. This gives more reliable coverage than mocking unit tests within ActiveRecord itself.

If you'd like to see Unreliable in action on a small but real Rails app locally, you can do this:

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
3.0.1 :001 > puts Post.where(title: "abc").to_sql
   (0.7ms)  SELECT sqlite_version(*)
SELECT "posts".* FROM "posts" WHERE "posts"."title" = 'abc' ORDER BY RAND()
```

## Future development

When new minor versions of ActiveRecord or Ruby are released, I will update the Appraisals file and run `bundle exec appraisal update` as well as the install, and update the matrix in the ci.yml workflow. There will be a patch-level release for these changes, even if no Unreliable code changes are required.

## See also

[chaotic_order](https://rubygems.org/gems/chaotic_order)
