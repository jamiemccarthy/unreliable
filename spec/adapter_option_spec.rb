# frozen_string_literal: true

RSpec.describe "rspec adapter" do
  it "is as specified" do
    expect(ActiveRecord::Base.connection.adapter_name.downcase).to eq(UnreliableTest.find_adapter!)
  end
end
