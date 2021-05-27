# frozen_string_literal: true

module ArQueryMatchers
  module Queries
    # An instance of this interface must be provided to the QueryCounter class.
    # it allows one to customize which queries it wants to capture.
    class QueryFilter
      # @param _name [String] the name of the ActiveRecord operation (this is sometimes garbage)
      # For example: "User Load"
      #
      # @param _sql [String] the sql query that was executed
      # For example: "SELECT  `users`.* FROM `users` .."
      #
      # @return nil or an instance which responds to #model_name (see TableName)
      # By returning nil we omit the query
      # By not returning nil, we are associating this query with a model_name.
      def filter_map(_name, _sql)
        raise NotImplementedError
      end
    end
  end
end
