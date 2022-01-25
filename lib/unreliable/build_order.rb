# frozen_string_literal: true

# Override ActiveRecord::QueryMethods.build_order to always append a final ORDER(RAND())

module Unreliable
  module BuildOrder

    def build_order(arel)
      super
      arel.order('RAND()') # TODO: for postgres, RANDOM()
    end

  end
end
