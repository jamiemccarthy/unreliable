# frozen_string_literal: true

class UnreliableTest
  DEFAULT_ADAPTER = "sqlite3".freeze
  VALID_ADAPTERS = ["mysql2", "postgresql", "sqlite3"].freeze
  DATABASE_YML_FILENAME = "spec/internal/config/database.yml".freeze

  def self.get_adapter!
    ENV['RSPEC_ADAPTER'].presence || ::UnreliableTest::DEFAULT_ADAPTER
  end

  def self.assert_valid_adapter!(adapter)
    raise "RSPEC_ADAPTER '#{adapter}' not valid" unless ::UnreliableTest::VALID_ADAPTERS.include? adapter
  end

  def self.cp_adapter_file(adapter)
    FileUtils.cp(
      "#{::UnreliableTest::DATABASE_YML_FILENAME}.#{adapter}",
      ::UnreliableTest::DATABASE_YML_FILENAME
    )
  end
end

require "bundler"

Bundler.require :default, :development

if ActiveRecord.gem_version >= Gem::Version.new("5.2") && ActiveRecord.gem_version < Gem::Version.new("6.0")
  # This setting was introduced in Rails 5.2, made the default in Rails 6.0, and
  # removed in Rails 6.1.
  require "active_record/connection_adapters/sqlite3_adapter"
  ActiveRecord::ConnectionAdapters::SQLite3Adapter.represent_boolean_as_integer = true
end

Combustion.initialize! :active_record

# Convert the sqlite3 version of the text that each test is expecting to see,
# into the text that the adapter would produce.

def adapter_text(sql)
  case ActiveRecord::Base.connection.adapter_name
  when "Mysql2"
    sql.gsub(/"/, "`").gsub(/RANDOM\(\)/, "RAND()")
  when "pg"
    sql.gsub(/"/, "`")
  else
    sql
  end
end

# ActiveRecord checks textual .order() arguments to ensure they match the adapter.
# This converts a textual order to match each adapter.

def order_text(sql)
  case ActiveRecord::Base.connection.adapter_name
  when "Mysql2"
    sql.gsub(/"/, "`")
  else
    sql
  end
end

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

  # Set the adapter for this run by copying the appropriate file into place.
  adapter = ::UnreliableTest.get_adapter!
  ::UnreliableTest.assert_valid_adapter!(adapter)
  ::UnreliableTest.cp_adapter_file(adapter)
  puts "Running RSpec for #{adapter}"
end
