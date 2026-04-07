# frozen_string_literal: true

RSpec.describe Cat do
  it "randomly selects in main query and subquery" do
    # rubocop:disable Layout/SpaceInsideParens,Layout/DotPosition
    expect( Cat.where(name: Cat.where(name: "foo")).to_sql ).
      to end_with(
        case UnreliableTest.find_adapter
        when "sqlserver"
          # SQL Server strips ORDER BY from IN subqueries; only the outer query gets NEWID()
          ") ORDER BY NEWID()"
        else
          adapter_text( %q[WHERE "cats"."name" = 'foo' ORDER BY RANDOM()) ORDER BY RANDOM()] )
        end
      )
    # rubocop:enable Layout/SpaceInsideParens,Layout/DotPosition
  end
end
