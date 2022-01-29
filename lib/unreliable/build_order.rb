# frozen_string_literal: true

# Override ActiveRecord::QueryMethods.build_order to always append a final ORDER(RAND())

require "active_record/connection_adapters/abstract_adapter"

module Unreliable
  module BuildOrder
    def build_order(arel)
      super

      return unless Unreliable::Config.enabled

      # TODO: is it worth caching this "case," or is it theoretically possible to have
      # an ActiveRecord that connects to two databases of different types?

      case Arel::Table.engine.connection.adapter_name
      when "Mysql2"
        # https://dev.mysql.com/doc/refman/8.0/en/mathematical-functions.html#function_rand
        arel.order("RAND()")

      when "SQLite"
        # https://www.sqlite.org/lang_corefunc.html#random
        arel.order("RANDOM()")

      when "PostgreSQL"
        # https://www.postgresql.org/docs/13/functions-math.html#FUNCTIONS-MATH-RANDOM-TABLE
        arel.order("RANDOM()")

      else
        # TODO: Do nothing, I guess? Or issue a deprecation/unsupported warning (once)?
      end
    end
  end
end
