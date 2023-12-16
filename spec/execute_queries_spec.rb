# frozen_string_literal: true

class CatTest < UnreliableTest
  # 12 factorial is about half a billion possible shuffles
  NAMES = %w[angus Rashad bertha harry moka bubbles Morty Tofu Purrito Neffy Zoe stinky].freeze
  RESPONSE_COUNT = 10
end

RSpec.describe Cat do
  it "adds and selects all cats" do
    expect(Cat.count).to eq(0)
    CatTest::NAMES.shuffle.each { |name| Cat.new(name: name).save! }
    expect(Cat.all.to_a.size).to eq(CatTest::NAMES.size)
  ensure
    Cat.delete_all
  end

  it "adds, updates-via-instance, and selects some cats" do
    # TODO: remove extra logging
    ActiveRecord::Base.logger = Logger.new($stdout)
    ActiveRecord::Base.logger.level = :debug
    expect(Cat.count).to eq(0)
    CatTest::NAMES.shuffle.each { |name| Cat.new(name: name).save! }
    expect(Cat.where(name: "Rashad").to_a.size).to eq(1)
    expect(Cat.where("name LIKE '%a%'").to_a.size).to eq(5)
    Cat.find_by(name: "harry").destroy!
    expect(Cat.where("name LIKE '%a%'").to_a.size).to eq(4)
    Cat.where("name NOT LIKE '%a%'").first.update!(name: "Mantissa")
    expect(Cat.where("name LIKE '%a%'").to_a.size).to eq(5)
  ensure
    Cat.delete_all
  end

  it "adds, updates-via-class, and selects some cats" do
    expect(Cat.count).to eq(0)
    CatTest::NAMES.shuffle.each { |name| Cat.new(name: name).save! }
    expect(Cat.where(name: "Rashad").to_a.size).to eq(1)
    expect(Cat.where("name LIKE '%a%'").to_a.size).to eq(5)
    Cat.find_by(name: "harry").destroy!
    expect(Cat.where("name LIKE '%a%'").to_a.size).to eq(4)
    Cat.update(Cat.where("name NOT LIKE '%a%'").pluck(:id).first, name: "Mantissa")
    expect(Cat.where("name LIKE '%a%'").to_a.size).to eq(5)
  ensure
    Cat.delete_all
  end

  it "adds and selects all ordered data unpredictably" do
    expect(Cat.count).to eq(0)
    CatTest::NAMES.shuffle.each { |name| Cat.new(name: name).save! }
    responses = (1..CatTest::RESPONSE_COUNT).map do
      Cat.all.map(&:name).join(":")
    end
    # The chances that there's one repeat in 10 randomly-ordered SELECTs
    # is about 1 in ten billion, and we allow for that. The chances that
    # there's two and this test incorrectly fails is in the quintillionths.
    expect(responses.uniq.size).to(satisfy { |v| v >= 9 })
  ensure
    Cat.delete_all
  end

  it "adds and selects some ordered data unpredictably" do
    expect(Cat.count).to eq(0)
    CatTest::NAMES.shuffle.each { |name| Cat.new(name: name).save! }
    responses = (1..CatTest::RESPONSE_COUNT).map do
      Cat.where.not(name: "bubbles").map(&:name).join(":")
    end
    expect(responses.uniq.size).to(satisfy { |v| v >= 8 })
  ensure
    Cat.delete_all
  end

  it "adds and selects all ordered data predictably with order by id" do
    expect(Cat.count).to eq(0)
    CatTest::NAMES.shuffle.each { |name| Cat.new(name: name).save! }
    responses = (1..CatTest::RESPONSE_COUNT).map do
      Cat.order(:id).map(&:name).join(":")
    end
    expect(responses.uniq.size).to eq(1)
  ensure
    Cat.delete_all
  end

  it "adds and selects all ordered data predictably with order by name" do
    expect(Cat.count).to eq(0)
    CatTest::NAMES.shuffle.each { |name| Cat.new(name: name).save! }
    responses = (1..CatTest::RESPONSE_COUNT).map do
      Cat.order(:name).map(&:name).join(":")
    end
    expect(responses.uniq.size).to eq(1)
  ensure
    Cat.delete_all
  end

  it "adds and selects some ordered data predictably with order" do
    expect(Cat.count).to eq(0)
    CatTest::NAMES.shuffle.each { |name| Cat.new(name: name).save! }
    responses = (1..CatTest::RESPONSE_COUNT).map do
      Cat.where.not(name: "Groovy").order(:id).map(&:name).join(":")
    end
    expect(responses.uniq.size).to eq(1)
  ensure
    Cat.delete_all
  end

  it "adds and selects all ordered data predictably with disable" do
    expect(Cat.count).to eq(0)
    CatTest::NAMES.shuffle.each { |name| Cat.new(name: name).save! }
    responses =
      Unreliable::Config.disable do
        (1..CatTest::RESPONSE_COUNT).map do
          Cat.all.map(&:name).join(":")
        end
      end
    # This is testing the actual undefined database behavior that Unreliable
    # was created to account for! In practice it's quite rare to observe
    # differing results on sequential SELECTs. I can't quantify the chances
    # of it like I can with expected-truly-random behavior above, but I'm
    # making an educated guess here and saying if we see more than 3 of 10,
    # something went wrong with the gem disabling its behavior. But because
    # database and protocol documentation all says it can do whatever it
    # wants, the number of unique responses might be up to RESPONSE_COUNT!
    # If this test fails erroneously basically ever, I would think it
    # should be rewritten or removed!
    expect(responses.uniq.size).to(satisfy { |v| v <= 3 })
  ensure
    Cat.delete_all
  end
end
