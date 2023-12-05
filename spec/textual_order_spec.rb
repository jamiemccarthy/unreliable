# frozen_string_literal: true

RSpec.describe "textual order" do
  it "randomly selects from shelves ordered by textual id asc" do
    expect(Shelf.order("shelf_id ASC").to_sql).to end_with(adapter_text("ORDER BY shelf_id ASC, RANDOM()"))
  end

  it "randomly selects from shelves ordered by fully qualified textual id asc" do
    # We have to use adapter_text here to convert the string order clause because
    # ActiveRecord's column_name_with_order_matcher is adapter-specific and will
    # require it to match. I.e., the MySQL adapter requires table and column name
    # quoted with ``, the other two with "". Otherwise ActiveRecord raises
    # UnknownAttributeReference with: "Query method called with non-attribute argument(s)"
    expect(Shelf.order(order_text('"shelves"."shelf_id"')).to_sql).to end_with(adapter_text('ORDER BY "shelves"."shelf_id", RANDOM()'))
  end

  it "randomly selects from shelves ordered by textual position asc" do
    expect(Shelf.order("shelf_position ASC").to_sql).to end_with(adapter_text("ORDER BY shelf_position ASC, RANDOM()"))
  end

  it "randomly selects from shelves ordered by textual id desc" do
    expect(Shelf.order("shelf_id DESC").to_sql).to end_with(adapter_text("ORDER BY shelf_id DESC, RANDOM()"))
  end

  it "randomly selects from shelves ordered by textual position desc" do
    expect(Shelf.order("shelf_position DESC").to_sql).to end_with(adapter_text("ORDER BY shelf_position DESC, RANDOM()"))
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
