# frozen_string_literal: true

require_relative './query_counter'
require_relative './table_name'
require_relative './query_filter'

module ArQueryMatchers
  module Queries
    # A specialized QueryCounter for "updates".
    # It uses a simple regex to identify and parse sql UPDATE queries.
    # For more information, see the QueryCounter class.
    class UpdateCounter
      def self.instrument(&block)
        QueryCounter.new(UpdateQueryFilter.new).instrument(&block)
      end

      class UpdateQueryFilter < QueryFilter
        # Matches unnamed SQL operations like the following:
        # "UPDATE `bank_account_verifications` ..."
        TABLE_NAME_SQL_PATTERN = /UPDATE [`"](?<table_name>[^`"]+)[`"]/.freeze

        def filter_map(_name, sql)
          # for updates, name is always 'SQL', we have to rely on pattern matching on the query string instead.
          select_from_table = sql.match(TABLE_NAME_SQL_PATTERN)
          TableName.new(select_from_table[:table_name]) if select_from_table
        end
      end
    end
  end
end
