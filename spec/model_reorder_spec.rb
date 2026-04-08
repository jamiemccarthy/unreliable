# frozen_string_literal: true

# reorder replaces the existing order entirely. The gem should respond to the
# final state of the order, not an intermediate one.

RSpec.describe "reorder" do
  it "does not randomize when reordered to PK" do
    expect(Cat.order(:name).reorder(:id).to_sql).to end_with(adapter_rand('ORDER BY "cats"."id" ASC'))
  end

  it "randomizes when reordered away from PK" do
    expect(Cat.order(:id).reorder(:name).to_sql).to end_with(
      adapter_rand('ORDER BY "cats"."name" ASC, RANDOM()')
    )
  end

  it "randomizes when reordered to non-PK column" do
    expect(Cat.reorder(:name).to_sql).to end_with(adapter_rand('ORDER BY "cats"."name" ASC, RANDOM()'))
  end
end
