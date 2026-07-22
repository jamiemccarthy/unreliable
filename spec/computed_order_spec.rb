# frozen_string_literal: true

# An order can be a directional node (Ascending/Descending) wrapping a computed
# expression rather than a plain column. Those wrappers survive the
# Arel::Nodes::Ordering grep in order_columns, but their .expr is not an
# Arel::Attributes::Attribute and has no .relation. The wrapped expr can be any
# of several node classes -- a SqlLiteral, a NamedFunction, an aggregate, etc.
# None of them can cover a primary key, so the query must be randomized (and
# must not raise).
#
# Note: a plain string order like .order("name DESC") does NOT reach this code;
# it becomes a bare SqlLiteral that the Ordering grep drops (see
# textual_order_spec.rb). Only a *directional* node wrapping a non-column does.

RSpec.describe "computed order" do
  it "randomly selects when ordered by a string-key hash alias" do
    # No explicit Arel -- the idiomatic hash form. "name_len" isn't a real column,
    # so it becomes a quoted SqlLiteral identifier wrapped in a Descending node.
    expect(Cat.order("name_len" => :desc).to_sql).to end_with(
      adapter_rand('ORDER BY "name_len" DESC, RANDOM()')
    )
  end

  it "randomly selects when ordered by a SqlLiteral with a direction" do
    expect(Cat.order(Arel.sql("name_len").desc).to_sql).to end_with(
      adapter_rand("ORDER BY name_len DESC, RANDOM()")
    )
  end

  it "randomly selects when ordered by a function expression (NamedFunction)" do
    expect(Cat.order(Cat.arel_table[:name].lower.desc).to_sql).to end_with(
      adapter_rand('ORDER BY LOWER("cats"."name") DESC, RANDOM()')
    )
  end

  it "randomly selects when ordered by an aggregate expression (Count)" do
    expect(Cat.order(Cat.arel_table[:id].count.desc).to_sql).to end_with(
      adapter_rand('ORDER BY COUNT("cats"."id") DESC, RANDOM()')
    )
  end

  it "randomly selects when ordered by an arithmetic expression (Grouping)" do
    expect(Cat.order((Cat.arel_table[:id] + 1).desc).to_sql).to end_with(
      adapter_rand('ORDER BY ("cats"."id" + 1) DESC, RANDOM()')
    )
  end

  it "randomly selects on a composite-PK table ordered by a computed expression" do
    expect(Shelf.order(Arel.sql("LENGTH(contents)").asc).to_sql).to end_with(
      adapter_rand("ORDER BY LENGTH(contents) ASC, RANDOM()")
    )
  end

  it "does not randomize when the PK is covered even though a computed order is also present" do
    # order_columns must still recognize the real "id" attribute after skipping
    # the computed expression, so the covered-PK short-circuit still applies.
    expect(Cat.order(:id).order(Arel.sql("LENGTH(name)").desc).to_sql).to end_with(
      adapter_rand('ORDER BY "cats"."id" ASC, LENGTH(name) DESC')
    )
  end
end
