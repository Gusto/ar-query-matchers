# frozen_string_literal: true

require_relative './query_counter'
require_relative './table_name'
require_relative './model_name'
require_relative './query_filter'

module ArQueryMatchers
  module Queries
    # A specialized QueryCounter for "loads".
    # For more information, see the QueryCounter class.
    class DestroyCounter
      def self.instrument(&block)
        QueryCounter.new(DestroyQueryFilter.new).instrument(&block)
      end

      class DestroyQueryFilter < Queries::QueryFilter
        # Matches named SQL operations like the following:
        # 'User Destroy'
        MODEL_DESTROY_PATTERN = /\A(?<model_name>[\w:]+) (Delete|Destroy)\Z/

        # Matches unnamed SQL operations like the following:
        # "SELECT COUNT(*) FROM `users` ..."
        MODEL_SQL_PATTERN = /DELETE (?:(DELETE).)* FROM [`"](?<table_name>[^`"]+)[`"]/

        def filter_map(name, sql)
          match = name.match(MODEL_DESTROY_PATTERN)
          return ModelName.new(match[:model_name]) if match

          # Fall back to pattern-matching on the table name in a COUNT and looking
          # up the table name from ActiveRecord's Destroyed descendants.
          select_from_table = sql.match(MODEL_SQL_PATTERN)
          TableName.new(select_from_table[:table_name]) if select_from_table
        end
      end
    end
  end
end
