# frozen_string_literal: true

RSpec.describe Cat do
  it "randomly selects from all" do
    expect(Cat.all.to_sql).to end_with(adapter_text("ORDER BY RANDOM()"))
  end

  it "randomly selects from some" do
    expect(Cat.where(name: "foo").to_sql).to end_with(adapter_text("ORDER BY RANDOM()"))
  end

  it "adds randomness to existing order" do
    expect(Cat.order(:name).to_sql).to end_with(adapter_text('ORDER BY "cats"."name" ASC, RANDOM()'))
  end

  it "respects a disable block" do
    Unreliable::Config.disable do
      expect(Cat.where(name: "foo").to_sql).to_not end_with(adapter_text("ORDER BY RANDOM()"))
      expect(Cat.where(name: "foo").to_sql).to end_with(adapter_text(%q("cats"."name" = 'foo')))
    end
  end
end
