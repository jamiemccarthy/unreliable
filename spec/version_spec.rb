# frozen_string_literal: true

require "unreliable/version"

RSpec.describe Unreliable, "version" do
  it "is defined" do
    expect(Unreliable::VERSION).to be
  end

  it "is correct" do
    expect(Unreliable::VERSION).to start_with "0."
  end
end
