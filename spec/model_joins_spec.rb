# frozen_string_literal: true

# So far, unreliable does not try to know when it can omit the ORDER BY RANDOM()
# when joining tables. It's unnecessary in some of the below tests and a future
# version that's smart about joins might be able to omit it.

RSpec.describe "model_indexes_joins" do
  it "randomly selects from owner has_many cats" do
    expect(Owner.joins(:cats).all.to_sql).to end_with(adapter_text("ORDER BY RANDOM()"))
  end

  it "randomly selects from owner has_many ordered cats" do
    expect(Owner.joins(:cats).order("owners.id": :asc).all.to_sql).to end_with(adapter_text(", RANDOM()"))
    expect(Owner.joins(:cats).order(:"cats.id").all.to_sql).to end_with(adapter_text(", RANDOM()"))
    expect(Owner.joins(:cats).order(:"owners.id", "cats.id": :desc).all.to_sql).to end_with(adapter_text(", RANDOM()"))
    expect(Owner.joins(:cats).order(:"owners.id", :"cats.name").all.to_sql).to end_with(adapter_text(", RANDOM()"))
  end

  it "randomly selects from dreamer has_one dream" do
    expect(Dreamer.joins(:dream).all.to_sql).to end_with(adapter_text("ORDER BY RANDOM()"))
  end

  it "randomly selects from dreamer has_one ordered dream" do
    expect(Dreamer.joins(:dream).order("dreamers.id": :desc).all.to_sql).to end_with(adapter_text(", RANDOM()"))
    expect(Dreamer.joins(:dream).order(:"dreams.id").all.to_sql).to end_with(adapter_text(", RANDOM()"))
  end
end
