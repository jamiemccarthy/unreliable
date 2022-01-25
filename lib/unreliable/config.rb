# frozen_string_literal: true

module Unreliable
  class Config
    attr_reader :enabled

    def setup!
      @enabled = true
    end

    def self.disable
      @enabled = false
      yield
    ensure
      @enabled = true
    end
  end
end
