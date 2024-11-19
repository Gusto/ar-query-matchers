# frozen_string_literal: true

module ArQueryMatchers
  module Queries
    # An instance of this class is one of the values that could be returned from the QueryFilter#filter_map.
    # its accepts a name of an ActiveRecord model, for example: 'Company'.
    class FieldName
      attr_reader(:model_name)
      attr_reader(:model_value)

      def initialize(model_name, model_value)
        @model_name = model_name
        @model_value = model_value
      end
    end
  end
end
