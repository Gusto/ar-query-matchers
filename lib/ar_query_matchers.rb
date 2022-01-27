# frozen_string_literal: true

require 'ar_query_matchers/queries/create_counter'
require 'ar_query_matchers/queries/load_counter'
require 'ar_query_matchers/queries/update_counter'
require 'bigdecimal'

module ArQueryMatchers
  module ArQueryMatchers
    class Utility
      def self.remove_superfluous_expectations(expected)
        expected.select { |_, v| v.positive? }
      end
    end

    module CreateModels
      # The following will succeed:
      #    expect {
      #       WcRiskClass.create
      #       WcRiskClass.create
      #       Company.last
      #    }.to only_create_models(
      #       'WcRiskClass' => 2,
      #    )
      #
      RSpec::Matchers.define(:only_create_models) do |expected = {}|
        include MatcherConfiguration
        include MatcherErrors

        match do |block|
          @query_stats = Queries::CreateCounter.instrument(&block)
          Utility.remove_superfluous_expectations(expected) == @query_stats.query_counts
        end

        def failure_text
          expectation_failed_message('create')
        end
      end

      # The following will not succeed because the code creates models:
      #
      #    expect {
      #       WcRiskClass.create
      #       WcRiskClass.create
      #       Company.last
      #    }.to not_create_any_models
      #
      RSpec::Matchers.define(:not_create_any_models) do
        include MatcherConfiguration
        include MatcherErrors

        match do |block|
          @query_stats = Queries::CreateCounter.instrument(&block)
          @query_stats.query_counts.empty?
        end

        def failure_text
          no_queries_fail_message('create')
        end
      end
    end

    module LoadModels
      # The following will fail because the call to `User` is not expected, even
      # though the Payroll count is correct:
      #
      #    expect {
      #       Payroll.count
      #       Payroll.count
      #       User.count
      #    }.to only_load_models(
      #       'Payroll' => 2,
      #    )
      #
      # The following will succeed because the counts are exact:
      #
      #    expect {
      #       Payroll.count
      #       Payroll.count
      #       User.count
      #    }.to only_load_models(
      #       'Payroll' => 2,
      #       'User' => 1,
      #    )
      #
      RSpec::Matchers.define(:only_load_models) do |expected = {}|
        include MatcherConfiguration
        include MatcherErrors

        match do |block|
          @query_stats = Queries::LoadCounter.instrument(&block)
          Utility.remove_superfluous_expectations(expected) == @query_stats.query_counts
        end

        def failure_text
          expectation_failed_message('load')
        end
      end

      # The following will fail because the call to `User` is not expected, even
      # though the Payroll count is correct:
      #
      #    expect {
      #       Payroll.count
      #       Payroll.count
      #       User.count
      #    }.to only_load_at_most_models(
      #       'Payroll' => 2,
      #    )
      #
      # The following will succeed because the counts are exact:
      #
      #    expect {
      #       Payroll.count
      #       Payroll.count
      #       User.count
      #    }.to only_load_at_most_models(
      #       'Payroll' => 2,
      #       'User' => 1,
      #    )
      #
      RSpec::Matchers.define(:only_load_at_most_models) do |expected = {}|
        include MatcherConfiguration
        include MatcherErrors

        match do |block|
          @query_stats = Queries::LoadCounter.instrument(&block)
          Utility.remove_superfluous_expectations(expected) == @query_stats.query_counts
        end

        def failure_text
          expectation_failed_message('load')
        end
      end

      RSpec::Matchers.define(:not_load_any_models) do
        include MatcherConfiguration
        include MatcherErrors

        match do |block|
          @query_stats = Queries::LoadCounter.instrument(&block)
          @query_stats.query_counts.empty?
        end

        def failure_text
          no_queries_fail_message('load')
        end
      end

      # The following will succeed because `load_models` allows any value for
      # models not specified:
      #
      #    expect {
      #       Payroll.count
      #       Payroll.count
      #       User.count
      #    }.to load_models(
      #       'Payroll' => 2,
      #    )
      RSpec::Matchers.define(:load_models) do |expected = {}|
        include MatcherConfiguration
        include MatcherErrors

        match do |block|
          @query_stats = Queries::LoadCounter.instrument(&block)
          expected.each do |model_name, expected_count|
            expect(expected_count).to eq @query_stats.query_counts[model_name]
          end
        end

        def failure_text
          expectation_failed_message('load')
        end
      end
    end

    class UpdateModels
      # The following will succeed:
      #
      #    expect {
      #       WcRiskClass.last.update_attributes(id: 9999)
      #    }.to only_update_models(
      #       'WcRiskClass' => 1,
      #    )
      #
      RSpec::Matchers.define(:only_update_models) do |expected = {}|
        include MatcherConfiguration
        include MatcherErrors

        match do |block|
          @query_stats = Queries::UpdateCounter.instrument(&block)
          Utility.remove_superfluous_expectations(expected) == @query_stats.query_counts
        end

        def failure_text
          expectation_failed_message('update')
        end
      end

      # The following will not succeed because the code updates models:
      #
      #    expect {
      #       WcRiskClass.last.update_attributes(id: 9999)
      #    }.to not_update_any_models
      #
      RSpec::Matchers.define(:not_update_any_models) do
        include MatcherConfiguration
        include MatcherErrors

        match do |block|
          @query_stats = Queries::UpdateCounter.instrument(&block)
          @query_stats.query_counts.empty?
        end

        def failure_text
          no_queries_fail_message('update')
        end
      end
    end

    # Shared methods that are included in the matchers.
    # They configure it and ensure we get consistent and human readable error messages
    module MatcherConfiguration
      def self.included(base)
        if base.respond_to?(:failure_message)
          base.failure_message do |_actual|
            failure_text
          end
        else
          base.failure_message_for_should do |_actual|
            failure_text
          end
        end
      end

      def supports_block_expectations?
        true
      end
    end

    module MatcherErrors
      # Show the difference between expected and actual values with one value
      # per line. This is done by hand because as of this writing the author
      # doesn't understand how RSpec does its nice hash diff printing.
      def difference(keys)
        max_key_length = keys.reduce(0) { |max, key| [max, key.size].max }

        keys.map do |key|
          left = expected.fetch(key, 0)
          right = @query_stats.queries.fetch(key, {}).fetch(:count, 0)

          diff = "#{'+' if right > left}#{right - left}"

          "#{key.rjust(max_key_length, ' ')} – expected: #{left}, got: #{right} (#{diff})"
        end.compact
      end

      def source_lines(keys)
        line_frequency = @query_stats.query_lines_by_frequency
        keys_with_source_lines = keys.select { |key| line_frequency[key].present? }
        keys_with_source_lines.map do |key|
          source_lines = line_frequency[key].sort_by(&:last).reverse # Most frequent on top
          next if source_lines.blank?

          [
            "  #{key}"
          ] + source_lines.map { |line, count| "    #{count} #{'call'.pluralize(count)}: #{line}" } + [
            ''
          ]
        end
      end

      def no_queries_fail_message(crud_operation)
        "Expected ActiveRecord to not #{crud_operation} any records, got #{@query_stats.query_counts}\n\nWhere unexpected queries came from:\n\n#{source_lines(@query_stats.query_counts.keys).join("\n")}"
      end

      def expectation_failed_message(crud_operation)
        all_model_names = expected.keys + @query_stats.queries.keys
        model_names_with_wrong_count = all_model_names.reject { |key| expected[key] == @query_stats.queries[key][:count] }.uniq
        "Expected ActiveRecord to #{crud_operation} #{expected}, got #{@query_stats.query_counts}\nExpectations that differed:\n#{difference(model_names_with_wrong_count).join("\n")}\n\nWhere unexpected queries came from:\n\n#{source_lines(model_names_with_wrong_count).join("\n")}"
      end
    end
  end
end
