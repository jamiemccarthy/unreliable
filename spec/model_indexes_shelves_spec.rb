# frozen_string_literal: true

RSpec.describe "model_indexes_shelves" do
  it "randomly selects from shelves" do
    expect(Shelf.all.to_sql).to end_with(adapter_text("ORDER BY RANDOM()"))
  end

  it "randomly selects from some shelves" do
    expect(Shelf.where(contents: "foo").to_sql).to end_with(adapter_text("ORDER BY RANDOM()"))
  end

  it "randomly selects from shelves ordered by id" do
    expect(Shelf.order(:shelf_id).to_sql).to end_with(adapter_text('ORDER BY "shelves"."shelf_id" ASC, RANDOM()'))
  end

  it "randomly selects from shelves ordered by position" do
    expect(Shelf.order(:shelf_position).to_sql).to end_with(
      adapter_text('ORDER BY "shelves"."shelf_position" ASC, RANDOM()')
    )
  end

  it "nonrandomly selects from shelves ordered by id and position" do
    expect(Shelf.order(:shelf_id, :shelf_position).to_sql).to end_with(
      adapter_text('ORDER BY "shelves"."shelf_id" ASC, "shelves"."shelf_position" ASC')
    )
  end

  it "nonrandomly selects from some shelves ordered by id and position" do
    expect(Shelf.where(contents: "bar").order(:shelf_id, :shelf_position).to_sql).to end_with(
      adapter_text('ORDER BY "shelves"."shelf_id" ASC, "shelves"."shelf_position" ASC')
    )
  end
end
