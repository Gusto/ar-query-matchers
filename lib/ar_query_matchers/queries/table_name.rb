# frozen_string_literal: true

module ArQueryMatchers
  module Queries
    # An instance of this class is one of the values that could be returned from the QueryFilter#filter_map.
    # its accepts a name of a table in the database, for example: 'companies'.
    #
    # #model_name would transform the table name ('companies') into the ActiveRecord model name ('Company').
    # It relies on the class to be loaded in the global namespace, which should be the case if we issues a query through ActiveRecord.
    class TableName
      def initialize(table_name)
        @table_name = table_name
      end

      def model_name
        active_record_class_for_table(@table_name)&.name
      end

      private

      # We recalculate this each time because new classes might get loaded between queries
      def active_record_class_for_table(table_name)
        # Retrieve all (known) subclasses of ActiveRecord::Base
        klasses = ActiveRecord::Base.descendants.reject(&:abstract_class)

        # Group them by their table_names
        tables = klasses.each_with_object(Hash.new { |k, v| k[v] = [] }) do |klass, accumulator|
          accumulator[klass.table_name] << klass
        end
        # Structure:
        # { 'users' => [User, AtoUser],
        #   'employees => [Employee, PandaFlows::StateFields] }

        # Of all the models that share the same table name sort them by their
        # relative ancestry and pick the one that all the rest inherit from
        tables[table_name].min_by { |a, b| a.ancestors.include?(b) }
      end
    end
  end
end
