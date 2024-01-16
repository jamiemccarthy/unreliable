# frozen_string_literal: true

RSpec.describe Cat do
  it "randomly selects in main query and subquery" do
    # rubocop:disable Layout/SpaceInsideParens,Layout/DotPosition
    expect( Cat.where(name: Cat.where(name: "foo")).to_sql ).
      to end_with(adapter_text( %q[WHERE "cats"."name" = 'foo' ORDER BY RANDOM()) ORDER BY RANDOM()] ))
    # rubocop:enable Layout/SpaceInsideParens,Layout/DotPosition
  end
end
