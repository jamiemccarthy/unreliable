# frozen_string_literal: true

# The gem explicitly skips randomization for ar_internal_metadata queries.
# In Rails < 7.1, InternalMetadata is an ActiveRecord model and queries go through
# build_arel. In Rails >= 7.1, it's a plain Ruby class and never hits build_order,
# so the check is only exercisable on older Rails.

RSpec.describe "ar_internal_metadata" do
  ar_71_plus = ActiveRecord.gem_version >= Gem::Version.new("7.1")

  it "does not randomize ar_internal_metadata queries",
    skip: (ar_71_plus ? "InternalMetadata is not an AR model in Rails >= 7.1" : false) do
    sql = ActiveRecord::InternalMetadata.all.to_sql
    expect(sql).to_not include("RANDOM()")
    expect(sql).to_not include("RAND()")
    expect(sql).to_not include("NEWID()")
  end
end
