# frozen_string_literal: true

class UnreliableTest
  DEFAULT_ADAPTER = "sqlite"
  VALID_ADAPTERS = %w[mysql2 postgresql sqlite trilogy sqlserver].freeze
  ORIG_EXTENSION = "orig"
  DATABASE_YML_FILENAME = "spec/internal/config/database.yml"

  def self.find_adapter
    ENV["RSPEC_ADAPTER"].presence || ::UnreliableTest::DEFAULT_ADAPTER
  end

  def self.assert_valid_adapter!(adapter)
    advice =
      case adapter
      when "mysql"
        " (maybe you meant mysql2?)"
      when "postgres", "pg"
        " (maybe you meant postgresql?)"
      else
        ""
      end
    raise "RSPEC_ADAPTER '#{adapter}' not valid#{advice}" unless ::UnreliableTest::VALID_ADAPTERS.include? adapter
  end

  def self.cp_adapter_file(adapter)
    FileUtils.cp(
      "#{::UnreliableTest::DATABASE_YML_FILENAME}.#{adapter}",
      ::UnreliableTest::DATABASE_YML_FILENAME
    )
  end

  def self.restore_adapter_file
    cp_adapter_file(::UnreliableTest::ORIG_EXTENSION)
  end
end

# Suppress specific C-extension deprecation warnings from old gems (sqlite3 1.3.x,
# activerecord 5.2 sqlite3_adapter) that fire at load time and on every query.
# These use rb_warning() without the :deprecated category tag, so
# Warning[:deprecated] = false does not suppress them. Prepending onto Warning's
# singleton class lets super work correctly to pass through all other warnings.
if RUBY_VERSION >= "2.7"
  Warning.singleton_class.prepend(Module.new do
    def warn(msg, **kwargs)
      return if %w[rb_tainted_str_new rb_check_safe_obj].any? { |s| msg.include?(s) }

      super
    end
  end)
end

require "bundler"
# This require "logger" is needed for the Rails 6.1 / Ruby 3.2 combination,
# which is buggy. Rails never loaded it, Ruby stopped loading it, so if
# we don't do it manually we get a "uninitialized constant Logger".
require "logger"

Bundler.require :default, :development

if ActiveRecord.gem_version >= Gem::Version.new("5.2") && ActiveRecord.gem_version < Gem::Version.new("6.0")
  # This setting was introduced in Rails 5.2, made the default in Rails 6.0, and
  # removed in Rails 6.1.
  require "active_record/connection_adapters/sqlite3_adapter"
  ActiveRecord::ConnectionAdapters::SQLite3Adapter.represent_boolean_as_integer = true
end

if ActiveRecord.gem_version >= Gem::Version.new("6.1") && ActiveRecord.gem_version < Gem::Version.new("7.1")
  # This causes all Rails deprecation warnings to raise.
  # Introduced in Rails 6.1. Upper bound is Rails 7.1, where this singleton API was
  # itself deprecated in favor of Rails.application.deprecators (handled below after
  # Combustion.initialize!).
  ActiveSupport::Deprecation.disallowed_warnings = :all
end

if ActiveRecord.gem_version >= Gem::Version.new("5.2") && ActiveRecord.gem_version < Gem::Version.new("6.1")
  # This setting was introduced in Rails 5.2, deprecated in Rails 6.1, and
  # removed in Rails 7.0.
  ActiveRecord::Base.allow_unsafe_raw_sql = :disabled
end

# Convert the sqlite3 version of the text that each test is `expect`ing to see,
# into the text that the adapter would produce.

def adapter_text(sql)
  case ActiveRecord::Base.connection.adapter_name
  when "Mysql2", "Trilogy"
    sql.tr('"', "`").gsub("RANDOM()", "RAND()")
  when "SQLServer"
    sql.gsub(/"([^"]+)"/, '[\\1]').gsub("RANDOM()", "NEWID()")
  else # PostgreSQL, SQLite
    sql
  end
end

# ActiveRecord checks textual .order() arguments to ensure they match the adapter.
# This converts our test's text to match. See spec/textual_order_spec.rb for more.

def order_text(sql)
  case ActiveRecord::Base.connection.adapter_name
  when "Mysql2", "Trilogy"
    sql.tr('"', "`")
  when "SQLServer"
    sql.gsub(/"([^"]+)"/, '[\\1]')
  else
    sql
  end
end

# Set the adapter for this run by copying the appropriate file into place.
adapter = UnreliableTest.find_adapter
UnreliableTest.assert_valid_adapter!(adapter)
UnreliableTest.cp_adapter_file(adapter)
puts "Running RSpec for #{adapter} on ActiveRecord #{ActiveRecord.version} on ruby #{RUBY_VERSION}"

Combustion.initialize! :active_record

if ActiveRecord.gem_version >= Gem::Version.new("7.1")
  # Rails.application.deprecators was introduced in Rails 7.1.
  # In Rails 7.2+, ActiveSupport::Deprecation singleton was removed entirely.
  # Must be called after Combustion.initialize! (Rails.application not available before).
  Rails.application.deprecators.each { |d| d.disallowed_warnings = :all }
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

  config.after(:suite) do
    UnreliableTest.restore_adapter_file
  end
end
