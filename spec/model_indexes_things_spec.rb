# frozen_string_literal: true

RSpec.describe "model_indexes_things" do
  it "randomly selects from things" do
    expect(Thing.all.to_sql).to end_with("ORDER BY RANDOM()")
  end

  it "nonrandomly selects from things by implied primary key descending" do
    expect(Thing.all.order(id: :desc).to_sql).to end_with('ORDER BY "things"."id" DESC')
  end
end
