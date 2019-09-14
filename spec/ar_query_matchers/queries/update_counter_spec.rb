# frozen_string_literal: true

# @mission Infrastructure
# @team DEx

require_relative '../mock_data_model'

RSpec.describe ArQueryMatchers::Queries::UpdateCounter do
  include_context('mock_data_model')

  it 'does not include reads or creates' do
    stats = described_class.instrument do
      MockUser.create!
      MockUser.last
    end

    expect(stats.query_counts).to be_empty
  end

  it 'records updates' do
    user_1 = MockUser.create!
    user_2 = MockUser.create!
    post = MockPost.create!(mock_user: user_1)

    stats = described_class.instrument do
      user_1.update!(name: 'name 1')
      user_1.update!(name: 'name 2')
      post.update!(mock_user: user_2)
    end

    expect(stats.query_counts).to eq('MockUser' => 2, 'MockPost' => 1)
  end
end
