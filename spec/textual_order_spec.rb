# frozen_string_literal: true

RSpec.describe "textual order" do
  it "randomly selects from shelves ordered by textual id asc" do
    expect(Shelf.order("shelf_id ASC").to_sql).to end_with(
      adapter_text("ORDER BY shelf_id ASC, RANDOM()")
    )
  end

  # This next test is a funny one written in a funny way, using the utility function
  # `order_text` -- which is used only here -- and here's why.
  #
  # Start by reading the docs for `order`, especially the "strings" and "Arel"
  # sections:
  # https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-order
  #
  # The docs claim "only strings composed of plain column names" are allowed,
  # but this has been incorrect since Rails 6.0, when column names with a table
  # prefix have been allowed:
  # https://github.com/rails/rails/blob/v6.0.0/activerecord/lib/active_record/connection_adapters/abstract/quoting.rb#L171-L194
  #
  # This test is to ensure that unreliable works even when an app writes an order
  # in this undocumented way. So here we want to send Shelf.order() a fully-qualified
  # textual order, i.e., an order that (unnecessarily, as it happens) specifies
  # table name along with column name.
  #
  # To test this across all three supported databases, we have to use `order_text`
  # to convert the string specifying the order into whichever format the current
  # adapter is expecting. What this means is that the MySQL adapter will require
  # the table and column name quoted with `backticks` and the other two "quotes".
  # If that were wrong, ActiveRecord would raise:
  # UnknownAttributeReference with: "Query method called with non-attribute argument(s)"
  #
  # So `order_text` ensures we send the adapter the correct format.
  # Then `adapter_text`, as usual, makes sure we check the result in the right way.

  it "randomly selects from shelves ordered by fully qualified textual id asc" do
    expect(Shelf.order(order_text('"shelves"."shelf_id"')).to_sql).to end_with(
      adapter_text('ORDER BY "shelves"."shelf_id", RANDOM()')
    )
  end

  it "randomly selects from shelves ordered by textual position asc" do
    expect(Shelf.order("shelf_position ASC").to_sql).to end_with(
      adapter_text("ORDER BY shelf_position ASC, RANDOM()")
    )
  end

  it "randomly selects from shelves ordered by textual id desc" do
    expect(Shelf.order("shelf_id DESC").to_sql).to end_with(
      adapter_text("ORDER BY shelf_id DESC, RANDOM()")
    )
  end

  it "randomly selects from shelves ordered by textual position desc" do
    expect(Shelf.order("shelf_position DESC").to_sql).to end_with(
      adapter_text("ORDER BY shelf_position DESC, RANDOM()")
    )
  end

  it "randomly selects from shelves ordered by textual id and position asc" do
    expect(Shelf.order("shelf_id ASC, shelf_position ASC").to_sql).to end_with(
      adapter_text("ORDER BY shelf_id ASC, shelf_position ASC, RANDOM()")
    )
  end

  it "randomly selects from shelves ordered by textual id and position desc" do
    expect(Shelf.order("shelf_id DESC, shelf_position DESC").to_sql).to end_with(
      adapter_text("ORDER BY shelf_id DESC, shelf_position DESC, RANDOM()")
    )
  end
end
