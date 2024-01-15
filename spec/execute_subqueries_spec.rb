# frozen_string_literal: true

class DreamTest < UnreliableTest
  SUBJECTS = %w[fire air water earth life death].freeze
  DREAMER_NAMES = %w[Morpheus Cluracan Mervyn Gilbert Nuala].freeze
  raise ArgumentError, "DreamTest needs at least as many subjects as dreamers" if SUBJECTS.size < DREAMER_NAMES.size

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

  it "deletes some dreams and dreamers" do
    expect(Dream.count).to eq(0)
    DreamTest::SUBJECTS.shuffle.each { |subject| Dream.new(subject: subject).save! }
    expect(Dream.all.to_a.size).to eq(DreamTest::SUBJECTS.size)

    one_dream_subject_per_dreamer = DreamTest::SUBJECTS.shuffle
    DreamTest::DREAMER_NAMES.shuffle.each do |dreamer_name|
      expect(one_dream_subject_per_dreamer.size).to(satisfy { |v| v > 0 })
      dream = Dream.find_by(subject: one_dream_subject_per_dreamer.shift)
      Dreamer.new(name: dreamer_name, dream: dream).save!
    end
    expect(Dreamer.all.to_a.size).to eq(DreamTest::DREAMER_NAMES.size)
    expect(Dream.all.pluck(:dreamer_id).compact.size).to eq(DreamTest::DREAMER_NAMES.size)

    sample_dreamer = Dreamer.find_by(name: DreamTest::DREAMER_NAMES.sample)
    expect(Dream.where(dreamer: sample_dreamer).to_a.size).to eq(1)
    Dream.where(dreamer: sample_dreamer).delete_all
    expect(Dream.all.size).to eq(DreamTest::SUBJECTS.size - 1)
  ensure
    Dreamer.delete_all
    Dream.delete_all
  end
end
