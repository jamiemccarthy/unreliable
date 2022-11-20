# frozen_string_literal: true

RSpec.describe Unreliable do
  it "does nothing in prod" do
    Rails.env = "production"
    expect(Cat.where(word: "foo").to_sql).to end_with(%q(WHERE "cats"."word" = 'foo'))
  ensure
    Rails.env = "test"
  end

  it "does nothing in dev" do
    Rails.env = "development"
    expect(Cat.where(word: "foo").to_sql).to end_with(%q(WHERE "cats"."word" = 'foo'))
  ensure
    Rails.env = "test"
  end
end
