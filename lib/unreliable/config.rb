# frozen_string_literal: true

module Unreliable
  class Config
    def self.setup!
      @enabled = true
    end

    def self.enabled?
      @enabled && Rails.env.test?
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
