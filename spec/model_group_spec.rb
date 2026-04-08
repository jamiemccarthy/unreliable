# frozen_string_literal: true

# GROUP BY queries get ORDER BY RANDOM() appended after the HAVING clause.
# This is semantically harmless -- the DB groups first, then sorts.
# Aggregate queries like .count use a separate code path and don't get ORDER BY.

RSpec.describe "group and having" do
  it "randomly selects with group" do
    expect(Cat.group(:name).to_sql).to end_with(adapter_rand("ORDER BY RANDOM()"))
  end

  it "randomly selects with group and having" do
    expect(Cat.group(:name).having("count(*) > 0").to_sql).to end_with(adapter_rand("ORDER BY RANDOM()"))
  end

  it "executes group with count correctly" do
    Cat.new(name: "Jinx").save!
    Cat.new(name: "Jinx").save!
    Cat.new(name: "Pixel").save!
    result = Cat.group(:name).count
    expect(result).to eq({"Jinx" => 2, "Pixel" => 1})
  ensure
    Cat.delete_all
  end

  it "executes group with having correctly" do
    Cat.new(name: "Jinx").save!
    Cat.new(name: "Jinx").save!
    Cat.new(name: "Pixel").save!
    result = Cat.group(:name).having("count(*) > 1").count
    expect(result).to eq({"Jinx" => 2})
  ensure
    Cat.delete_all
  end
end
