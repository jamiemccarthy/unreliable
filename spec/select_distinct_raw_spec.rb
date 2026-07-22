# frozen_string_literal: true

# DISTINCT written as a raw string in .select (rather than via the .distinct
# relation method) does not set distinct_value. Without detecting it, the gem
# appends ORDER BY RANDOM(), which PostgreSQL and SQL Server reject:
#
#   for SELECT DISTINCT, ORDER BY expressions must appear in select list
#   SELECT DISTINCT ON expressions must match initial ORDER BY expressions
#
# On MySQL and SQLite the appended random order is accepted, so -- as with the
# .distinct relation method -- those adapters still get randomized.

RSpec.describe "raw DISTINCT in select" do
  it "does not append a randomizing order to a raw DISTINCT select on postgres/sqlserver" do
    expect(Cat.select("DISTINCT name").to_sql).to end_with(
      case UnreliableTest.find_adapter
      when "postgresql", "sqlserver"
        adapter_quotes('DISTINCT name FROM "cats"')
      else
        adapter_rand("ORDER BY RANDOM()")
      end
    )
  end

  it "does not append a randomizing order to a raw DISTINCT ON select on postgres",
    skip: (UnreliableTest.find_adapter == "postgresql" ? false : "DISTINCT ON is PostgreSQL-only syntax") do
    expect(Cat.select("DISTINCT ON (name) *").to_sql).to end_with(
      adapter_rand('SELECT DISTINCT ON (name) * FROM "cats"')
    )
  end

  it "still detects DISTINCT written in lowercase" do
    expect(Cat.select("distinct name").to_sql).to end_with(
      case UnreliableTest.find_adapter
      when "postgresql", "sqlserver"
        adapter_quotes('distinct name FROM "cats"')
      else
        adapter_rand("ORDER BY RANDOM()")
      end
    )
  end

  it "does not treat an aggregate's inner DISTINCT as a statement-level DISTINCT" do
    # count(DISTINCT ...) is not a SELECT DISTINCT, so the query must still be randomized.
    expect(Cat.select("count(DISTINCT name) AS n").to_sql).to end_with(
      adapter_rand("ORDER BY RANDOM()")
    )
  end

  it "executes a raw DISTINCT select without a server error" do
    expect { Cat.select("DISTINCT name").load }.not_to raise_error
  end

  it "executes a raw DISTINCT ON select without a server error",
    skip: (UnreliableTest.find_adapter == "postgresql" ? false : "DISTINCT ON is PostgreSQL-only syntax") do
    expect { Cat.select("DISTINCT ON (name) *").load }.not_to raise_error
  end
end
