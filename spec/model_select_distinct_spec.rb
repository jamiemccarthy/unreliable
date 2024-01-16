# frozen_string_literal: true

RSpec.describe Cat do
  it "randomly selects distinctly except on postgres" do
    expect(Cat.distinct.all.to_sql).to end_with(
      UnreliableTest.find_adapter == "postgresql" ? ' FROM "cats"' : adapter_text("ORDER BY RANDOM()")
    )
  end

  it "randomly selects distinctly from some" do
    expect(Cat.where(name: "foo").distinct.to_sql).to end_with(
      UnreliableTest.find_adapter == "postgresql" ? %q{ "cats"."name" = 'foo'} : adapter_text("ORDER BY RANDOM()")
    )
  end

  it "adds randomness to existing distinct order" do
    expect(Cat.order(:name).distinct.to_sql).to end_with(
      UnreliableTest.find_adapter == "postgresql" ? ' ORDER BY "cats"."name" ASC' : adapter_text('ORDER BY "cats"."name" ASC, RANDOM()')
    )
  end

  it "executes a distinct" do
    expect(Cat.distinct.count).to eq(0)
    Cat.new(name: "Chet").save!
    Cat.new(name: "Cab").save!
    Cat.new(name: "Oscar").save!
    Cat.new(name: "Chet").save!
    expect(Cat.select(:name).to_a.size).to eq(4)
    expect(Cat.select(:name).distinct.to_a.size).to eq(3)
  ensure
    Cat.delete_all
  end
end
