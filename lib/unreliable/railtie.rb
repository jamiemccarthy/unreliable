# frozen_string_literal: true

require "active_record/relation"
require "active_record/relation/query_methods"

module Unreliable
  class Railtie < Rails::Railtie
    config.to_prepare do
      Unreliable::Config.setup!
    end

    initializer "random_test_order.active_record_patch" do
      if Rails.env.test?
        # TODO: check earliest Rails version that supports this
        # https://edgeapi.rubyonrails.org/classes/ActiveSupport/LazyLoadHooks.html
        ActiveSupport.on_load(:active_record) do
          ::ActiveRecord::QueryMethods.prepend ::Unreliable::BuildOrder
        end
      end
    end
  end
end
