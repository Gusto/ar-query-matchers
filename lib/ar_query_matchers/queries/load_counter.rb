# frozen_string_literal: true

require_relative './query_counter'
require_relative './table_name'
require_relative './model_name'
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
        # Matches named SQL operations like the following:
        # 'User Load'
        MODEL_LOAD_PATTERN = /\A(?<model_name>[\w:]+) (Load|Exists)\Z/.freeze

        # Matches unnamed SQL operations like the following:
        # "SELECT COUNT(*) FROM `users` ..."
        MODEL_SQL_PATTERN = /SELECT .* FROM [`"](?<table_name>[^`"]+)[`"]/.freeze

        def filter_map(name, sql)
          # First check for a `SELECT * FROM` query that ActiveRecord has
          # helpfully named for us in the payload
          match = name.match(MODEL_LOAD_PATTERN)
          return ModelName.new(match[:model_name]) if match

          # Fall back to pattern-matching on the table name in a COUNT and looking
          # up the table name from ActiveRecord's loaded descendants.
          select_from_table = sql.match(MODEL_SQL_PATTERN)
          TableName.new(select_from_table[:table_name]) if select_from_table
        end
      end
    end
  end
end
