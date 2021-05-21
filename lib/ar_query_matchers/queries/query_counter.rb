# frozen_string_literal: true

module ArQueryMatchers
  module Queries
    # The QueryCounter instruments a ruby block and collect stats on the
    # SQL queries performed during its execution.
    #
    # It's "generic" meaning it requires an instance of a QueryFilter to operate.
    # The QueryFilter is an interface that both filters SQL statements and maps them to an ActiveRecord model, sort of a Enumerator#filter_map.
    #
    # This class is meant to be wrapped by another class that provides a concrete QueryFilter implementation.
    # For example, you could implement a SelectQueryFilter using it:
    # class SelectQueryCounter
    #   class SelectFilter < Queries::QueryFilter
    #     def extract(_name, sql)
    #       select_from_table = sql.match(/SELECT .* FROM [`"](?<table_name>[^`"]+)[`"]/)
    #       Queries::TableName.new(select_from_table[:table_name]) if select_from_table
    #     end
    #   end
    #
    #   def self.instrument(&block)
    #     QueryCounter.new(SelectFilter.new).instrument(&block)
    #   end
    # end
    #
    # stats = SelectQueryCounter.instrument do
    #   Company.first
    #   Employee.last(100)
    #   User.find(1)
    #   User.find(2)
    # end
    #
    # stats.query_counts == { 'Company' => 1, Employee => '1', 'User' => 2 }
    class QueryCounter
      class QueryStats
        def initialize(queries)
          @queries = queries
        end

        attr_reader(:queries)

        # @return [Hash] of model name to query count, for example: { 'Company' => 5}
        def query_counts
          Hash[*queries.reduce({}) { |acc, (model_name, data)| acc.update model_name => data[:count] }.sort_by(&:first).flatten]
        end

        # @return [Hash] of line in the source code to its frequency
        def query_lines_by_frequency
          queries.reduce({}) do |lines, (model_name, data)|
            frequencies = data[:lines].reduce(Hash.new { |h, k| h[k] = 0 }) do |freq, line|
              freq.update line => freq[line] + 1
            end
            lines.update model_name => frequencies
          end
        end
      end

      def initialize(query_filter)
        @query_filter = query_filter
      end

      # @param [block] block to instrument
      # @return [QueryStats] stats about all the SQL queries executed during the block
      def instrument(&block)
        queries = Hash.new { |h, k| h[k] = { count: 0, lines: [], time: BigDecimal(0) } }
        ActiveSupport::Notifications.subscribed(to_proc(queries), 'sql.active_record', &block)
        QueryStats.new(queries)
      end

      private

      # The 'marginalia' gem adds a line from the backtrace to the SQL query in
      # the form of a comment.
      MARGINALIA_SQL_COMMENT_PATTERN = %r{/*line:(?<line>.*)'*/}.freeze
      private_constant :MARGINALIA_SQL_COMMENT_PATTERN

      def to_proc(queries)
        lambda do |_name, start, finish, _message_id, payload|
          return if payload[:cached]

          # Given a `sql.active_record` event, figure out which model is being
          # accessed. Some of the simpler queries have a :name key that makes this
          # really easy. Others require parsing the SQL by hand.
          results = @query_filter.filter_map(payload[:name] || '', payload[:sql] || '')

          # Round to microseconds
          results&.each do |result|
            model_name = result.model_name
            next unless model_name

            comment = payload[:sql].match(MARGINALIA_SQL_COMMENT_PATTERN)
            queries[model_name][:lines] << comment[:line] if comment
            queries[model_name][:count] += 1
            queries[model_name][:time] += (finish - start).round(6) # Round to microseconds
          end
        end
      end
    end
  end
end
