# frozen_string_literal: true

# Cat.first internally does order(:id).limit(1). Since the PK is fully covered
# by the order, unreliable should NOT add RANDOM(). We can't call .to_sql on
# first/last (they return records), so we test the equivalent Relation.

RSpec.describe "first and last" do
  it "does not randomize the query equivalent to .first" do
    expect(Cat.order(:id).limit(1).to_sql).to end_with(
      "#{adapter_rand('ORDER BY "cats"."id" ASC')} #{adapter_limit(1)}"
    )
  end

  it "does not randomize the query equivalent to .last" do
    expect(Cat.order(id: :desc).limit(1).to_sql).to end_with(
      "#{adapter_rand('ORDER BY "cats"."id" DESC')} #{adapter_limit(1)}"
    )
  end

  it "executes first and last without error" do
    Cat.new(name: "Alfa").save!
    Cat.new(name: "Bravo").save!
    expect(Cat.first.name).to be_a(String)
    expect(Cat.last.name).to be_a(String)
  ensure
    Cat.delete_all
  end
end
