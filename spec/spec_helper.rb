# frozen_string_literal: true

require "bundler"

Bundler.require :default, :development

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
