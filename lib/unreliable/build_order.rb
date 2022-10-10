# frozen_string_literal: true

# Override ActiveRecord::QueryMethods.build_order to append a final ORDER(RAND()) when necessary

require "active_record/connection_adapters/abstract_adapter"

module Unreliable
  module BuildOrder
    def build_order(arel)
      super(arel)

      return unless Unreliable::Config.enabled?
      return if from_only_internal_metadata?(arel)
      return if from_all_ordered_pk?(arel)

      case Arel::Table.engine.connection.adapter_name
      when "Mysql2"
        # https://dev.mysql.com/doc/refman/8.0/en/mathematical-functions.html#function_rand
        arel.order("RAND()")

      when "PostgreSQL", "SQLite"
        # https://www.postgresql.org/docs/13/functions-math.html#FUNCTIONS-MATH-RANDOM-TABLE
        # https://www.sqlite.org/lang_corefunc.html#random
        arel.order("RANDOM()")

      else
        raise ArgumentError, "unknown Arel::Table.engine"

      end
    end

    def from_only_internal_metadata?(arel)
      arel.froms.map(&:name) == [ActiveRecord::Base.internal_metadata_table_name]
    end

    def from_all_ordered_pk?(arel)
      arel.froms.map(&:name).all? do |from_table_name|
        # For each table referenced, the primary key's column(s) must be covered by the order columns.
        (
          [ActiveRecord::Base.connection.primary_key(from_table_name)].flatten -
            arel.orders.map(&:expr)
              .select { |e| e.relation.name == from_table_name }
              .map(&:name)
              .map(&:to_s) # In Rails < 5.2, the order names are symbols; >= 5.2, strings
        ).empty?
      end
    end
  end
end
