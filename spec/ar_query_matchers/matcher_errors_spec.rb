# frozen_string_literal: true

# @mission Infrastructure
# @team DEx

require 'active_support/core_ext/object/blank'

# The `query_by_field*` matchers can't be driven end-to-end from this suite: FieldCounter's patterns
# match MySQL's backtick-quoted identifiers, and the suite runs on SQLite. So exercise the failure
# message builder directly against hand-built query stats.
RSpec.describe ArQueryMatchers::ArQueryMatchers::MatcherErrors do
  subject(:matcher) do
    Class.new do
      include ArQueryMatchers::ArQueryMatchers::MatcherErrors

      def initialize(expected, queries)
        @expected = expected
        @query_stats = ArQueryMatchers::Queries::QueryCounter::QueryStats.new(queries)
      end

      attr_reader(:expected, :query_stats)
    end.new(expected, queries)
  end

  # Mirrors what QueryCounter#instrument builds: a Hash whose default block *assigns* on lookup.
  def stats_hash(values_by_key)
    hash = Hash.new { |h, k| h[k] = { count: 0, lines: [], values: [], time: 0 } }
    values_by_key.each { |key, values| hash[key] = { count: values.size, lines: [], values: values, time: 0 } }
    hash
  end

  describe '#expectation_failed_message with ignore_missing' do
    context 'when an expected key was queried but recorded no values' do
      let(:expected) { { 'company_id' => [1], 'member_id' => [2] } }
      let(:queries) { stats_hash('company_id' => [99], 'member_id' => []) }

      it 'reports both differing keys' do
        message = matcher.expectation_failed_message('query_by', show_values: true, subset: true, ignore_missing: true)

        expect(message).to include('company_id – expected: [1], got: [99]')
        expect(message).to include('member_id – expected: [2], got: []')
      end
    end

    context 'when an expected key was never queried' do
      let(:expected) { { 'company_id' => [1], 'member_id' => [2] } }
      let(:queries) { stats_hash('company_id' => [99]) }

      it 'ignores the missing key' do
        message = matcher.expectation_failed_message('query_by', show_values: true, subset: true, ignore_missing: true)

        expect(message).to include('company_id – expected: [1], got: [99]')
        expect(message).not_to include('member_id – expected')
      end

      it 'does not report the missing key as a query that happened' do
        matcher.expectation_failed_message('query_by', show_values: true, subset: true, ignore_missing: true)

        expect(matcher.query_stats.query_values).to eq('company_id' => [99])
      end
    end
  end

  describe '#expectation_failed_message without values' do
    let(:expected) { { 'MockUser' => 1 } }
    let(:queries) { stats_hash('MockPost' => [1, 2]) }

    it 'does not record the expected-but-unqueried model as queried' do
      matcher.expectation_failed_message('load')

      expect(matcher.query_stats.query_counts).to eq('MockPost' => 2)
    end
  end
end
