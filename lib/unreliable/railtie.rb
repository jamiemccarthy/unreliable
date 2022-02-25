# frozen_string_literal: true

require "active_record/relation"
require "active_record/relation/query_methods"

module Unreliable
  class Railtie < Rails::Railtie
    config.to_prepare do
      Unreliable::Config.setup!
    end

    initializer "unreliable.build_order_patch" do
      if Rails.env.test?
        ActiveSupport.on_load(:active_record) do
          ::ActiveRecord::QueryMethods.prepend ::Unreliable::BuildOrder
        end
      end
    end
  end
end
