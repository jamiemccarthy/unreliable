# frozen_string_literal: true

RSpec.describe Cat do
  it "randomly selects in main query and subquery" do
    sql = Cat.where(name: Cat.where(name: "foo")).to_sql.gsub("  ", " ")
    expect(sql).to end_with(adapter_text("ORDER BY RANDOM()"))
    # SQL Server forbids ORDER BY in an IN-subquery without TOP, so the gem
    # correctly cannot append NEWID() inside the subquery on that adapter.
    unless ActiveRecord::Base.connection.adapter_name == "SQLServer"
      expect(sql).to include(adapter_text(%q[WHERE "cats"."name" = 'foo' ORDER BY RANDOM()]))
    end
  end
end
