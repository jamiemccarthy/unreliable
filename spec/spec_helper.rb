# frozen_string_literal: true

require "bundler"

Bundler.require :default, :development

if ActiveRecord.gem_version >= Gem::Version.new("5.2") && ActiveRecord.gem_version < Gem::Version.new("6.0")
  # This setting was introduced in Rails 5.2, made the default in Rails 6.0, and
  # removed in Rails 6.1.
  require "active_record/connection_adapters/sqlite3_adapter"
  ActiveRecord::ConnectionAdapters::SQLite3Adapter.represent_boolean_as_integer = true
end

Combustion.initialize! :active_record

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.warnings = true
  config.default_formatter = "doc" if config.files_to_run.count == 1
end
