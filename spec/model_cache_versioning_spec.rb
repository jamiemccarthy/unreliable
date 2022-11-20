# frozen_string_literal: true

# collection_cache_versioning was added in Rails 6.0. It performs a
# SELECT COUNT(*), MAX(updated_at) which will have an unnecessary ORDER BY RANDOM()
# applied to it. That shouldn't hurt anything. This is a simple way to both
# cover that important code and ensure Unreliable works correctly with
# aggregate SELECTs.

RSpec.describe Cat do
  it "in ActiveRecord >= 6.0, calculates cache versions",
    skip: ((ActiveRecord::VERSION::MAJOR < 6) ? "test is for ActiveRecord >= 6.0 only" : false) do
    old_setting = ActiveRecord::Base.collection_cache_versioning
    ActiveRecord::Base.collection_cache_versioning = true
    Cat.new(name: "spot").save!
    Cat.new(name: "sadie").save!
    expect(Cat.where("name LIKE 's%'").cache_version).to start_with("2-")
    expect(Cat.where(name: "foo").cache_version).to eq("0")
  ensure
    Cat.delete_all
    ActiveRecord::Base.collection_cache_versioning = old_setting
  end
end
