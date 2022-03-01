# frozen_string_literal: true

RSpec.describe Thing do
  it "randomly selects in main query and subquery" do
    # rubocop:disable Layout/SpaceInsideParens,Layout/DotPosition
    expect( Thing.where(word: Thing.where(word: "foo")).to_sql ).
      to end_with( %q[WHERE "things"."word" = 'foo' ORDER BY RANDOM()) ORDER BY RANDOM()] )
    # rubocop:enable Layout/SpaceInsideParens,Layout/DotPosition
  end
end
