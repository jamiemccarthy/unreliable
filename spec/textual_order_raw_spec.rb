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
# To test non-quoted column and/or table names, across all three supported
# databases, we have to use `order_text` to convert the string specifying
# the order into whichever format the current adapter is expecting. What
# this means is that in the tests where we quote table and/or column name,
# the MySQL adapter will require the table and column name quoted with
# `backticks` and the other two with "quotes".
#
# To make this work, `order_text` ensures we send the adapter the correct format.
# Then `adapter_text`, as usual, makes sure we check the result in the right way.
#
# This test is to ensure that unreliable works even when an app writes an order
# in this not-well-documented way. So here we want to send Shelf.order() a
# fully-qualified textual order, i.e., an order that (unnecessarily, as it happens)
# specifies table name along with column name.
#
# We do this with spec_helper.rb having set the strictest setting for raw sql,
# "ActiveRecord::Base.allow_unsafe_raw_sql = :disabled", in the ActiveRecord
# versions where that's available -- which is only 5.2 and 6.0. This may have
# been an ill-advised setting because it makes ordering by quoted column
# and/or table names raise an UnknownAttributeReference error only in 5.2.
# Maybe this unexpected change is why this feature was quickly deprecated and
# removed. We test 5.2 separately from other verions.

RSpec.describe "textual order raw" do
  it "randomly selects from shelves ordered by Arel-escaped quoted table and column name" do
    expect(Shelf.order(Arel.sql(order_text('"shelves"."shelf_id"'))).to_sql).to end_with(
      adapter_text('ORDER BY "shelves"."shelf_id", RANDOM()')
    )
  end

  it "randomly selects from shelves ordered by Arel-escaped quoted column name" do
    expect(Shelf.order(Arel.sql(order_text('"shelf_id"'))).to_sql).to end_with(
      adapter_text('ORDER BY "shelf_id", RANDOM()')
    )
  end

  it "raises (in 5.2) on non-Arel-escaped quoted table and column name",
    skip: ((ActiveRecord.version < Gem::Version.new("5.2") || ActiveRecord.version >= Gem::Version.new("6.0")) ? "test is for ActiveRecord 5.2 only" : false) do
    # It actually raises ActiveRecord::UnknownAttributeReference, but since that's
    # not defined in earlier versions of Rails, referencing that would itself raise!
    # So we name that class by its superclass here.
    expect { Shelf.order(order_text('"shelves"."shelf_id"')).to_sql }.to raise_error(ActiveRecord::ActiveRecordError)
  end

  it "raises (in 5.2) on non-Arel-escaped quoted column name",
    skip: ((ActiveRecord.version < Gem::Version.new("5.2") || ActiveRecord.version >= Gem::Version.new("6.0")) ? "test is for ActiveRecord 5.2 only" : false) do
    expect { Shelf.order(order_text('"shelf_id"')).to_sql }.to raise_error(ActiveRecord::ActiveRecordError)
  end

  it "randomly selects (except in 5.2) on non-Arel-escaped quoted table and column name",
    skip: ((ActiveRecord.version >= Gem::Version.new("5.2") && ActiveRecord.version < Gem::Version.new("6.0")) ? "test is not for ActiveRecord 5.2" : false) do
    expect(Shelf.order(order_text('"shelves"."shelf_id"')).to_sql).to end_with(
      adapter_text('ORDER BY "shelves"."shelf_id", RANDOM()')
    )
  end

  it "randomly selects (except in 5.2) on non-Arel-escaped quoted column name",
    skip: ((ActiveRecord.version >= Gem::Version.new("5.2") && ActiveRecord.version < Gem::Version.new("6.0")) ? "test is not for ActiveRecord 5.2" : false) do
    expect(Shelf.order(order_text('"shelf_id"')).to_sql).to end_with(
      adapter_text('ORDER BY "shelf_id", RANDOM()')
    )
  end

  it "randomly selects from shelves ordered by non-Arel-escaped unquoted table and column name" do
    expect(Shelf.order("shelves.shelf_id").to_sql).to end_with(
      adapter_text("ORDER BY shelves.shelf_id, RANDOM()")
    )
  end

  it "randomly selects from shelves ordered by non-Arel-escaped unquoted column name" do
    expect(Shelf.order("shelf_id").to_sql).to end_with(
      adapter_text("ORDER BY shelf_id, RANDOM()")
    )
  end
end
