# frozen_string_literal: true

require_relative './query_counter'
require_relative './field_name'
require_relative './query_filter'

module ArQueryMatchers
  module Queries
    # A specialized QueryCounter for "any action that involves field IDs".
    # For more information, see the QueryCounter class.
    class FieldCounter
      def self.instrument(&block)
        QueryCounter.new(FieldCounterFilter.new).instrument(&block)
      end

      # Filters queries for counting purposes
      class FieldCounterFilter < Queries::QueryFilter
        # We need to look for a few things:
        # Anything with ` {field} = {value}` (this could be a select, update, delete)
        MODEL_FIELDS_PATTERN = /\.`(?<field_name>\w+)` = (?<field_value>[\w"`]+)/

        # Anything with ` {field} IN ({value})` (this could be a select, update, delete)
        MODEL_FIELDS_IN_PATTERN = /\.`(?<field_name>\w+)` IN \((?<field_value>[\w"`]+)\)/

        # Anything with `, field,` in an INSERT (we need to check the values)
        MODEL_INSERT_PATTERN = /INSERT INTO (?<table_name>[^`"]+) ... VALUES .../

        def cleanup(value)
          cleaned_value = value.gsub '`', ''

          # If this is an integer, we'll cast it automatically
          cleaned_value = value.to_i if cleaned_value == value

          cleaned_value
        end

        def filter_map(_name, sql)
          # We need to look for a few things:
          #   - Anything with ` {field} = ` (this could be a select, update, delete)
          #   - Anything with `, field,` in an INSERT (we need to check the values)
          select_field_query = sql.match(MODEL_FIELDS_PATTERN)
          # debugger if sql.match(/INSERT/)
          # TODO: MODEL_FIELDS_IN_PATTERN and MODEL_INSERT_PATTERN need to be handled

          FieldName.new(select_field_query[:field_name], cleanup(select_field_query[:field_value])) if select_field_query
        end
      end
    end
  end
end
