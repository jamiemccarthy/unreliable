# frozen_string_literal: true

RSpec.describe Thing do
  it "randomly selects from all" do
    expect(Thing.all.to_sql).to end_with("ORDER BY RANDOM()")
  end

  it "randomly selects from some" do
    expect(Thing.where(word: "foo").to_sql).to end_with("ORDER BY RANDOM()")
  end

  it "respects a disable block" do
    Unreliable::Config.disable do
      expect(Thing.where(word: "foo").to_sql).to_not end_with("ORDER BY RANDOM()")
      expect(Thing.where(word: "foo").to_sql).to end_with(%q("things"."word" = 'foo'))
    end
  end
end
