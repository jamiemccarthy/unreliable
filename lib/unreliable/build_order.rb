# frozen_string_literal: true

# Override ActiveRecord::QueryMethods.build_order to append a final ORDER(RAND()) when necessary

require "active_record/connection_adapters/abstract_adapter"

module Unreliable
  module BuildOrder
    def build_order(arel)
      super(arel)

      return unless Unreliable::Config.enabled?
      return if from_only_internal_metadata?(arel)
      return if from_one_table_with_ordered_pk?(arel)

      case Arel::Table.engine.connection.adapter_name
      when "Mysql2"
        # https://dev.mysql.com/doc/refman/8.0/en/mathematical-functions.html#function_rand
        arel.order("RAND()")

      when "PostgreSQL", "SQLite"
        # https://www.postgresql.org/docs/16/functions-math.html#FUNCTIONS-MATH-RANDOM-TABLE
        # https://www.sqlite.org/lang_corefunc.html#random
        arel.order("RANDOM()")

      else
        raise ArgumentError, "unknown Arel::Table.engine"

      end
    end

    def from_only_internal_metadata?(arel)
      # No need to randomize queries on ar_internal_metadata
      arel.froms.map(&:name) == [ActiveRecord::Base.internal_metadata_table_name]
    end

    def from_one_table_with_ordered_pk?(arel)
      # This gem isn't (yet) capable of determining if ordering is reliable when two or
      # more tables are being joined.
      return false if arel.ast.cores.first.source.is_a?(Arel::Nodes::JoinSource) &&
        arel.ast.cores.first.source.right.present?
      return false if arel.froms.count > 1

      # If the single table's primary key's column(s) are covered by the order columns,
      # return true and don't randomize the order.
      (primary_key_columns(arel) - order_columns(arel)).empty?
    end

    def primary_key_columns(arel)
      # primary_keys returns a String if it's one column, an Array if two or more.
      # Using the SchemaCache minimizes the number of times we have to, e.g. in MySQL,
      # SELECT column_name FROM information_schema.statistics
      # (or in Rails < 6, SELECT column_name FROM information_schema.key_column_usage)
      [ActiveRecord::Base.connection.schema_cache.primary_keys(arel.froms.first.name)].flatten
    end

    def order_columns(arel)
      from_table_name = arel.froms.first.name
      arel.orders
        .select { |order| order.is_a? Arel::Nodes::Ordering } # Don't try to parse textual orders
        .map(&:expr)
        .select { |expr| expr.relation.name == from_table_name }
        .map(&:name)
        .map(&:to_s) # In Rails < 5.2, the order column names are symbols; >= 5.2, strings
    end
  end
end
