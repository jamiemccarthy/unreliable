# frozen_string_literal: true

RSpec.describe Unreliable::Config do
  it "restores state after nested disable blocks" do
    expect(Cat.all.to_sql).to end_with(adapter_rand("ORDER BY RANDOM()"))

    Unreliable::Config.disable do
      expect(Cat.all.to_sql).to_not include("RANDOM()")
      expect(Cat.all.to_sql).to_not include("RAND()")

      Unreliable::Config.disable do
        expect(Cat.all.to_sql).to_not include("RANDOM()")
        expect(Cat.all.to_sql).to_not include("RAND()")
      end

      # Still disabled after inner block
      expect(Cat.all.to_sql).to_not include("RANDOM()")
      expect(Cat.all.to_sql).to_not include("RAND()")
    end

    # Re-enabled after outer block
    expect(Cat.all.to_sql).to end_with(adapter_rand("ORDER BY RANDOM()"))
  end
end
