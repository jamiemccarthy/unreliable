# frozen_string_literal: true

# These are funny tests written in funny ways, using the utility function
# `order_text` -- which is used only here -- and here's why.
#
# Start by reading the docs for `order`, especially the "strings" and "Arel"
# sections:
# https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-order
#
# The docs claim "only strings composed of plain column names" are allowed,
# but "plain" (since at least Rails 5.2) has allowed a table prefix as well, e.g.:
# https://github.com/rails/rails/blob/v6.0.0/activerecord/lib/active_record/connection_adapters/abstract/quoting.rb#L171-L194
#
# This test is to ensure that unreliable works even when an app writes an order
# in this undocumented way. So here we want to send Shelf.order() a fully-qualified
# textual order, i.e., an order that (unnecessarily, as it happens) specifies
# table name along with column name.
#
# TODO, THIS IS WRONG, IT SHOULD NOT HAVE TO BE QUOTED, AT LEAST NOT IN MYSQL:
# To test this across all three supported databases, we have to use `order_text`
# to convert the string specifying the order into whichever format the current
# adapter is expecting. What this means is that the MySQL adapter will require
# the table and column name quoted with `backticks` and the other two "quotes".
# If that were wrong, ActiveRecord would raise:
# UnknownAttributeReference with: "Query method called with non-attribute argument(s)"
#
# So `order_text` ensures we send the adapter the correct format.
# Then `adapter_text`, as usual, makes sure we check the result in the right way.

# So I believe the rules should be:
# AR 5.2-6.0: ActiveRecord::Base.allow_unsafe_raw_sql = :disabled
# 1. quote table/column names for the adapter, Arel.sql escape
# 2. AR 6: quote table/column names, no Arel.sql, expect raise
# 3. unquoted table/column names

RSpec.describe "textual order raw" do
  it "randomly selects from shelves ordered by Arel-escaped fully-qualified textual id asc" do
    expect(Shelf.order(Arel.sql(order_text('"shelves"."shelf_id"'))).to_sql).to end_with(
      adapter_text('ORDER BY "shelves"."shelf_id", RANDOM()')
    )
  end

  it "raises on non-Arel-escaped quoted table and column names",
    skip: ((ActiveRecord::VERSION::MAJOR == 6) ? "test is for ActiveRecord 6 only" : false) do
    expect(Shelf.order(order_text('"shelves"."shelf_id"')).to_sql).to raise_error(
      ActiveRecord::UnknownAttributeReference, "Query method called with non-attribute argument"
    )
  end

  it "raises on non-Arel-escaped quoted column names",
    skip: ((ActiveRecord::VERSION::MAJOR == 6) ? "test is for ActiveRecord 6 only" : false) do
    expect(Shelf.order(order_text('"shelf_id"')).to_sql).to raise_error(
      ActiveRecord::UnknownAttributeReference, "Query method called with non-attribute argument"
    )
  end

  it "randomly selects from shelves ordered by unquoted fully-qualified textual id asc" do
    expect(Shelf.order("shelves.shelf_id"))).to_sql).to end_with(
      adapter_text('ORDER BY shelves.shelf_id, RANDOM()')
    )
  end
end
