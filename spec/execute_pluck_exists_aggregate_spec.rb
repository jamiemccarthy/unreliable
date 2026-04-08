# frozen_string_literal: true

# pluck, exists?, and aggregate methods (count, sum, minimum, maximum) all go
# through build_arel and get ORDER BY RANDOM() appended. The ordering is harmless
# for aggregates (result is the same regardless) and silently discarded for pluck.
# These tests verify the methods return correct values despite the appended ORDER BY.

RSpec.describe "pluck, exists?, and aggregates" do
  before do
    Cat.new(name: "Alfie").save!
    Cat.new(name: "Bella").save!
    Cat.new(name: "Cleo").save!
  end

  after { Cat.delete_all }

  it "pluck returns correct values" do
    expect(Cat.pluck(:name).sort).to eq(%w[Alfie Bella Cleo])
  end

  it "pluck with where returns correct values" do
    expect(Cat.where(name: %w[Alfie Bella]).pluck(:name).sort).to eq(%w[Alfie Bella])
  end

  it "exists? returns true when matching rows exist" do
    expect(Cat.where(name: "Alfie").exists?).to be true
  end

  it "exists? returns false when no matching rows exist" do
    expect(Cat.where(name: "Nobody").exists?).to be false
  end

  it "count returns correct value" do
    expect(Cat.count).to eq(3)
    expect(Cat.where(name: %w[Alfie Bella]).count).to eq(2)
  end

  it "sum returns correct value" do
    ids = Cat.pluck(:id)
    expect(Cat.sum(:id)).to eq(ids.sum)
  end

  it "minimum and maximum return correct values" do
    ids = Cat.pluck(:id).sort
    expect(Cat.minimum(:id)).to eq(ids.first)
    expect(Cat.maximum(:id)).to eq(ids.last)
  end
end
