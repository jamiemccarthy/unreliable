# frozen_string_literal: true

module Unreliable
  class Config
    attr_reader :enabled

    def self.setup!
      @enabled = true
    end

    def self.disable
      prev_enabled = @enabled
      @enabled = false
      yield
    ensure
      @enabled = prev_enabled
    end
  end
end
