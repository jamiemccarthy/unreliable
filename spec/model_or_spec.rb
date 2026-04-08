# frozen_string_literal: true

RSpec.describe "or queries" do
  it "randomly selects with or" do
    expect(Cat.where(name: "foo").or(Cat.where(name: "bar")).to_sql).to end_with(
      adapter_text("ORDER BY RANDOM()")
    )
  end

  it "adds randomness to existing order with or" do
    expect(Cat.where(name: "foo").or(Cat.where(name: "bar")).order(:name).to_sql).to end_with(
      adapter_text('ORDER BY "cats"."name" ASC, RANDOM()')
    )
  end

  it "does not randomize when or query is ordered by primary key" do
    expect(Cat.where(name: "foo").or(Cat.where(name: "bar")).order(:id).to_sql).to end_with(
      adapter_text('ORDER BY "cats"."id" ASC')
    )
  end

  it "executes or query correctly" do
    Cat.new(name: "Alfie").save!
    Cat.new(name: "Bella").save!
    Cat.new(name: "Cleo").save!
    result = Cat.where(name: "Alfie").or(Cat.where(name: "Cleo")).pluck(:name).sort
    expect(result).to eq(%w[Alfie Cleo])
  ensure
    Cat.delete_all
  end
end
