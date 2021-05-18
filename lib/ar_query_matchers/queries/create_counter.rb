# frozen_string_literal: true

require_relative './query_counter'
require_relative './table_name'
require_relative './query_filter'

module ArQueryMatchers
  module Queries
    # A specialized QueryCounter for "creates".
    # It uses a simple regex to identify and parse sql INSERT queries.
    # For more information, see the QueryCounter class.
    class CreateCounter
      def self.instrument(&block)
        QueryCounter.new(CreateQueryFilter.new).instrument(&block)
      end

      class CreateQueryFilter < QueryFilter
        # Matches unnamed SQL operations like the following:
        # "INSERT INTO `company_approval_details` ..."
        TABLE_NAME_SQL_PATTERN = /INSERT INTO [`"](?<table_name>[^`"]+)[`"]/.freeze

        def filter_map(_name, sql)
          # for inserts, name is always 'SQL', we have to rely on pattern matching the query string.
          select_from_table = sql.match(TABLE_NAME_SQL_PATTERN)

          [TableName.new(select_from_table[:table_name])] if select_from_table
        end
      end
    end
  end
end
