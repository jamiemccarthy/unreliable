# frozen_string_literal: true

class UnreliableTest
  DEFAULT_ADAPTER = "sqlite3"
  VALID_ADAPTERS = %w[mysql2 postgresql sqlite3].freeze
  DATABASE_YML_FILENAME = "spec/internal/config/database.yml"

  def self.find_adapter!
    ENV["RSPEC_ADAPTER"].presence || ::UnreliableTest::DEFAULT_ADAPTER
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

if ActiveRecord.gem_version >= Gem::Version.new("6.1") && ActiveRecord.gem_version < Gem::Version.new("7.1")
  # This causes all Rails deprecation warnings to raise.
  # We would like to use this feature all the time, but it was only introduced in 6.1,
  # and combustion <= 1.3.7 throws a deprecation in Rails 7.1. The next release of
  # combustion should fix it: https://github.com/pat/combustion/pull/131
  ActiveSupport::Deprecation.disallowed_warnings = :all
end

if ActiveRecord.gem_version >= Gem::Version.new("5.2") && ActiveRecord.gem_version < Gem::Version.new("6.1")
  # This setting was introduced in Rails 5.2, deprecated in Rails 6.1, and
  # removed in Rails 7.0.
  ActiveRecord::Base.allow_unsafe_raw_sql = :disabled
end

Combustion.initialize! :active_record

# Convert the sqlite3 version of the text that each test is `expect`ing to see,
# into the text that the adapter would produce.

def adapter_text(sql)
  case ActiveRecord::Base.connection.adapter_name
  when "Mysql2"
    sql.tr('"', "`").gsub("RANDOM()", "RAND()")
  when "pg"
    sql.tr('"', "`")
  else
    sql
  end
end

# ActiveRecord checks textual .order() arguments to ensure they match the adapter.
# This converts our test's text to match. See spec/textual_order_spec.rb for more.

def order_text(sql)
  case ActiveRecord::Base.connection.adapter_name
  when "Mysql2"
    sql.tr('"', "`")
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
  config.raise_errors_for_deprecations!
  config.default_formatter = "doc" if config.files_to_run.count == 1

  # Set the adapter for this run by copying the appropriate file into place.
  adapter = UnreliableTest.find_adapter!
  UnreliableTest.assert_valid_adapter!(adapter)
  UnreliableTest.cp_adapter_file(adapter)
  puts "Running RSpec for #{adapter}"
end
