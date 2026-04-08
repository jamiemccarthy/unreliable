# frozen_string_literal: true

# LIMIT appears after ORDER BY in the generated SQL, so we use `include` to verify
# RANDOM()/RAND() is present rather than `end_with`.

RSpec.describe "limit without order" do
  it "randomly selects with limit" do
    sql = Cat.limit(5).to_sql
    expect(sql).to include(adapter_rand("ORDER BY RANDOM()"))
    expect(sql).to include(adapter_limit(5))
  end

  it "randomly selects with limit and where" do
    sql = Cat.where(name: "foo").limit(3).to_sql
    expect(sql).to include(adapter_rand("ORDER BY RANDOM()"))
    expect(sql).to include(adapter_limit(3))
  end
end
