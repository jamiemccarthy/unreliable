# unreliable

In a Rails test environment, patches ActiveRecord to have a final ORDER BY clause that returns results in a random order.

If the specified order for any relation is ambiguous, including if no order at all is specified, relational databases like [Postgres](https://www.postgresql.org/docs/14/queries-order.html) and MySQL do not define the resulting order. However, in practice they often happen to return the same order in many cases.

Authors of tests will often rely on this unreliable ordering, which leads to tests passing accidentally.

With Unreliable installed, the test suite will see all ActiveRecord relations with a final ORDER BY clause that replaces the ambiguity with randomness. Thus any tests that rely on the order of at least two records will break at least half the time.

It does nothing outside of test environments, and there is intentionally no way to enable Unreliable in any other environment.

# Implementation

We patch ActiveRecord::QueryMethods#build_arel, the point where an Arel is converted for use, to append an order to the existing order chain.

This means that the ORDER BY applies to not just SELECTs but e.g. delete_all and update_all. It also applies within subqueries.

By always appending the random order, we ensure unreliable ordering for relations that have no order at all, and also for relations with an ambiguous order. For example, ordering by a non-unique column, or a combination of multiple columns which together are non-unique.

# Fun trivia

Other ways you can order a relation ambiguously include:

* ORDER BY a column with values that differ only by [character case](https://dev.mysql.com/doc/refman/8.0/en/sorting-rows.html), 
* ORDER BY values that are identical within the [prefix length limit](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_max_sort_length) examined for sorting

# TODO

rubocop

tests!

# See also


