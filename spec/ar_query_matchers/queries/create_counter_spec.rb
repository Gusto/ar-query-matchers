# frozen_string_literal: true

# @mission Infrastructure
# @team DEx

require_relative '../mock_data_model'

RSpec.describe ArQueryMatchers::Queries::CreateCounter do
  include_context('mock_data_model')

  it 'does not include reads or creates' do
    user = MockUser.create!
    stats = described_class.instrument do
      user.update!(name: 'new name')
      MockUser.last
    end

    expect(stats.query_counts).to be_empty
  end

  it 'records creates' do
    stats = described_class.instrument do
      user_1 = MockUser.create!
      user_2 = MockUser.create!
      MockPost.create!(mock_user_id: user_1)
      MockPost.create!(mock_user_id: user_1)
      MockPost.create!(mock_user_id: user_2)
      MockPost.create!(mock_user_id: user_2)
    end

    expect(stats.query_counts).to eq('MockUser' => 2, 'MockPost' => 4)
  end
end
