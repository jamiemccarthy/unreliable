# frozen_string_literal: true

require 'minitest/autorun'
require 'unreliable/version'

class VersionTest < Minitest::Test
  def test_has_a_version
    assert Unreliable::VERSION
  end
end
