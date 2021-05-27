# frozen_string_literal: true

require_relative './query_counter'
require_relative './table_name'
require_relative './query_filter'

module ArQueryMatchers
  module Queries
    # A specialized QueryCounter for "loads".
    # For more information, see the QueryCounter class.
    class LoadCounter
      def self.instrument(&block)
        QueryCounter.new(LoadQueryFilter.new).instrument(&block)
      end

      class LoadQueryFilter < Queries::QueryFilter
        # Matches unnamed SQL operations like the following:
        # "SELECT * FROM `users` ..."
        MODEL_SQL_PATTERN = /SELECT (?:(?!SELECT).)* FROM [`"](?<table_name>[^`"]+)[`"]/.freeze

        def filter_map(_name, sql)
          # Pattern-matching on the table name in a SELECT ... FROM and looking
          # up the table name from ActiveRecord's loaded descendants.
          selects_from_table = sql.scan(MODEL_SQL_PATTERN)
          selects_from_table.map { |(table_name)| TableName.new(table_name) } unless selects_from_table.empty?
        end
      end
    end
  end
end
