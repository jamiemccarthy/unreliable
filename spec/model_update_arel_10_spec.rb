# frozen_string_literal: true

# ActiveRecord's update_all invokes compile_update for the Arel::SelectManager returned
# by build_arel. It returns an Arel::UpdateManager. This makes sure that internal call
# assembles the update query correctly.

module Unreliable
  class SqlTestingData
    class_attribute :update_manager_sql
  end
end

RSpec.describe "update_manager" do
  it "in ActiveRecord >= 7, updates by subquery with select in random order",
    skip: ((ActiveRecord::VERSION::MAJOR < 7) ? "test is for ActiveRecord >= 7 only" : false) do
    module Arel
      class SelectManager
        def testing_compile_update(*args)
          um = old_compile_update(*args)
          Unreliable::SqlTestingData.update_manager_sql = um.to_sql
          um
        end
        alias_method :old_compile_update, :compile_update
        alias_method :compile_update, :testing_compile_update
      end
    end

    # rubocop:disable Layout/SpaceInsideParens,Layout/DotPosition

    # Single subquery: "update cats where id in (select cats where name=bar)"
    Cat.where(name: "foo").update_all(name: "bar")
    expect(Unreliable::SqlTestingData.update_manager_sql).
      to end_with(adapter_text("ORDER BY RANDOM())"))

    # Double-nested subquery: "update cats where id in (select cats where id in (select owners where name=baz))"
    Cat.where( id: Owner.where(name: "bar") ).update_all(name: "baz")
    expect(Unreliable::SqlTestingData.update_manager_sql).
      to end_with(adapter_text("ORDER BY RANDOM()) ORDER BY RANDOM())"))

    # Single ordered subquery: "update cats where id in (select cats where name=bar order by id limit ?)"
    # The presence of the primary-key order means Unreliable does not apply its own order.
    Cat.where(name: "bar").order(:id).limit(1).update_all(name: "baz")
    expect(Unreliable::SqlTestingData.update_manager_sql).
      to end_with(adapter_text("ORDER BY \"cats\".\"id\" ASC LIMIT ?)"))

    # Single ordered subquery: "update cats where id in (select cats where name=bar limit ?)"
    Cat.where(name: "bar").limit(1).update_all(name: "baz")
    expect(Unreliable::SqlTestingData.update_manager_sql).
      to end_with(adapter_text("ORDER BY RANDOM() LIMIT ?)"))

    # rubocop:enable Layout/SpaceInsideParens,Layout/DotPosition
  ensure
    module Arel
      class SelectManager
        alias_method :compile_update, :old_compile_update
      end
    end
  end
end
