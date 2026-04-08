# frozen_string_literal: true

module Unreliable
  class Config
    def self.setup!
      @enabled = true
    end

    def self.enabled?
      @enabled && !Thread.current[:unreliable_disabled] && Rails.env.test?
    end

    def self.disable
      was_disabled = Thread.current[:unreliable_disabled]
      Thread.current[:unreliable_disabled] = true
      yield
    ensure
      Thread.current[:unreliable_disabled] = was_disabled
    end
  end
end
