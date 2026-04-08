# frozen_string_literal: true

# find_each and in_batches add ORDER BY id ASC internally for cursor-based
# iteration. The gem detects that the primary key is fully covered and correctly
# suppresses ORDER BY RANDOM(), leaving the batch queries intact.

RSpec.describe "find_each and in_batches" do
  before do
    %w[Baku Caer Chuangmu Gilgamesh Penelope].each { |name| Cat.create!(name: name) }
  end

  after { Cat.delete_all }

  it "find_each yields all records without error" do
    names = []
    Cat.find_each(batch_size: 2) { |cat| names << cat.name }
    expect(names.sort).to eq(%w[Baku Caer Chuangmu Gilgamesh Penelope])
  end

  it "in_batches iterates all records without error" do
    names = []
    Cat.in_batches(of: 2) { |batch| names.concat(batch.pluck(:name)) }
    expect(names.sort).to eq(%w[Baku Caer Chuangmu Gilgamesh Penelope])
  end

  it "find_each does not append random order" do
    sqls = []
    subscription = ActiveSupport::Notifications.subscribe("sql.active_record") do |*, payload|
      sqls << payload[:sql] if payload[:sql].include?("cats")
    end
    Cat.find_each(batch_size: 100) { next }
    ActiveSupport::Notifications.unsubscribe(subscription)
    expect(sqls).to all(satisfy { |sql|
      !sql.include?("RANDOM()") && !sql.include?("RAND()") && !sql.include?("NEWID()")
    })
  end

  it "in_batches does not append random order" do
    sqls = []
    subscription = ActiveSupport::Notifications.subscribe("sql.active_record") do |*, payload|
      sqls << payload[:sql] if payload[:sql].include?("cats")
    end
    Cat.in_batches(of: 100) { next }
    ActiveSupport::Notifications.unsubscribe(subscription)
    expect(sqls).to all(satisfy { |sql|
      !sql.include?("RANDOM()") && !sql.include?("RAND()") && !sql.include?("NEWID()")
    })
  end
end
