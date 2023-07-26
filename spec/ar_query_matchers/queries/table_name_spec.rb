# frozen_string_literal: true

# @mission Infrastructure
# @team DEx

require_relative '../mock_data_model'

RSpec.describe ArQueryMatchers::Queries::TableName do
  include_context('mock_data_model')

  let!(:my_special_mock_post_class) do
    Class.new(ModelBase) do
      self.table_name = 'mock_posts'

      def self.name
        'MySpecialMockPost'
      end

      belongs_to :mock_user
    end
  end

  it 'returns class name that is the shortest distance from the table name' do
    subject = ArQueryMatchers::Queries::TableName.new('mock_posts')
    expect(subject.model_name).to eq 'MockPost'

    subject = ArQueryMatchers::Queries::TableName.new('mock_users')
    expect(subject.model_name).to eq 'MockUser'
  end
end
