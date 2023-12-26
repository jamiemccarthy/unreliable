# frozen_string_literal: true

class DreamTest < UnreliableTest
  SUBJECTS = %w[fire air water earth life death].freeze
  DREAMER_NAMES = %w[Morpheus Cluracan Mervyn Gilbert Nuala].freeze
  RESPONSE_COUNT = 10
end

RSpec.describe Dream do
  it "adds and selects all dreams and dreamers" do
    expect(Dream.count).to eq(0)
    DreamTest::SUBJECTS.shuffle.each { |subject| Dream.new(subject: subject).save! }
    expect(Dream.all.to_a.size).to eq(DreamTest::SUBJECTS.size)
    DreamTest::DREAMER_NAMES.shuffle.each do |name|
      dream = Dream.find_by(subject: DreamTest::SUBJECTS.sample)
      Dreamer.new(name: name, dream: dream).save!
    end
    expect(Dreamer.all.to_a.size).to eq(DreamTest::DREAMER_NAMES.size)
  ensure
    Dreamer.delete_all
    Dream.delete_all
  end

  it "deleted some dreams and dreamers" do
    expect(Dream.count).to eq(0)
    DreamTest::SUBJECTS.shuffle.each { |subject| Dream.new(subject: subject).save! }
    expect(Dream.all.to_a.size).to eq(DreamTest::SUBJECTS.size)
    DreamTest::DREAMER_NAMES.shuffle.each do |name|
      dream = Dream.find_by(subject: DreamTest::SUBJECTS.sample)
      Dreamer.new(name: name, dream: dream).save!
    end
    expect(Dreamer.all.to_a.size).to eq(DreamTest::DREAMER_NAMES.size)
    # TODO: delete_all for where(something) and ensure the remainder exist;
    # ensure the sql generated for the delete_all does not do the "id"="id" thing
  ensure
    Dreamer.delete_all
    Dream.delete_all
  end
end
