# frozen_string_literal: true

# Override ActiveRecord::QueryMethods.build_order to always append a final ORDER(RAND())

require "active_record/connection_adapters/abstract_adapter"

module Unreliable
  module BuildOrder
    def build_order(arel)
      super

      return unless Unreliable::Config.enabled

      case Arel::Table.engine.connection.adapter_name
      when "Mysql2"
        # https://dev.mysql.com/doc/refman/8.0/en/mathematical-functions.html#function_rand
        arel.order("RAND()")

      when "SQLite"
        # https://www.sqlite.org/lang_corefunc.html#random
      when "PostgreSQL"
        # https://www.postgresql.org/docs/13/functions-math.html#FUNCTIONS-MATH-RANDOM-TABLE
        arel.order("RANDOM()")

      else
        raise ArgumentError, "unknown Arel::Table.engine"

      end
    end
  end
end
