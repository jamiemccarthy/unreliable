# frozen_string_literal: true

RSpec.describe "textual order" do
  it "randomly selects from shelves ordered by textual id asc" do
    expect(Shelf.order("shelf_id ASC").to_sql).to end_with("ORDER BY shelf_id ASC, RANDOM()")
  end

  it "randomly selects from shelves ordered by fully qualified textual id asc" do
    expect(Shelf.order('"shelves"."shelf_id"').to_sql).to end_with('ORDER BY "shelves"."shelf_id", RANDOM()')
  end

  it "randomly selects from shelves ordered by textual position asc" do
    expect(Shelf.order("shelf_position ASC").to_sql).to end_with("ORDER BY shelf_position ASC, RANDOM()")
  end

  it "randomly selects from shelves ordered by textual id desc" do
    expect(Shelf.order("shelf_id DESC").to_sql).to end_with("ORDER BY shelf_id DESC, RANDOM()")
  end

  it "randomly selects from shelves ordered by textual position desc" do
    expect(Shelf.order("shelf_position DESC").to_sql).to end_with("ORDER BY shelf_position DESC, RANDOM()")
  end

  it "randomly selects from shelves ordered by textual id and position asc" do
    expect(Shelf.order("shelf_id ASC, shelf_position ASC").to_sql).to end_with(
      "ORDER BY shelf_id ASC, shelf_position ASC, RANDOM()"
    )
  end

  it "randomly selects from shelves ordered by textual id and position desc" do
    expect(Shelf.order("shelf_id DESC, shelf_position DESC").to_sql).to end_with(
      "ORDER BY shelf_id DESC, shelf_position DESC, RANDOM()"
    )
  end
end
