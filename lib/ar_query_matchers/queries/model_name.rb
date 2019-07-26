# frozen_string_literal: true

module ArQueryMatchers
  module Queries
    # An instance of this class is one of the values that could be returned from the QueryFilter#filter_map.
    # its accepts a name of an ActiveRecord model, for example: 'Company'.
    class ModelName
      attr_reader(:model_name)

      def initialize(model_name)
        @model_name = model_name
      end
    end
  end
end
