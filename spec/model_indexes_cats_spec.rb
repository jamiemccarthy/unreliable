# frozen_string_literal: true

RSpec.describe "model_indexes_cats" do
  it "randomly selects from cats" do
    expect(Cat.all.to_sql).to end_with(adapter_text("ORDER BY RANDOM()"))
  end

  it "nonrandomly selects from cats by implied primary key descending" do
    expect(Cat.all.order(id: :desc).to_sql).to end_with(adapter_text('ORDER BY "cats"."id" DESC'))
  end
end
