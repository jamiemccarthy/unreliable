# frozen_string_literal: true

RSpec.describe "model_indexes_dreams" do
  it "randomly selects from dreams ordered by nonindexed column" do
    expect(Dream.all.order(:subject).to_sql).to end_with(adapter_text('ORDER BY "dreams"."subject" ASC, RANDOM()'))
  end

  it "nonrandomly selects from dreams by explicit primary key" do
    expect(Dream.all.order(:dream_id).to_sql).to end_with(adapter_text('ORDER BY "dreams"."dream_id" ASC'))
  end
end
