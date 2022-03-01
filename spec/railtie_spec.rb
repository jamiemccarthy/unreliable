# frozen_string_literal: true

RSpec.describe Unreliable::Railtie do
  it "has an initializer" do
    expect(Unreliable::Railtie.initializers.count).to eq(1)
  end

  it "has an initializer with the correct name" do
    expect(Unreliable::Railtie.initializers.first.name).to eq("unreliable.build_order_patch")
  end
end
