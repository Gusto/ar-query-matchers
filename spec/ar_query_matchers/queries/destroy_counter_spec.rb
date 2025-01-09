# frozen_string_literal: true

# @mission Infrastructure
# @team DEx

require_relative '../mock_data_model'

RSpec.describe ArQueryMatchers::Queries::DestroyCounter do
  include_context('mock_data_model')

  it 'does not include reads or creates or updates' do
    stats = described_class.instrument do
      MockUser.create!
      user = MockUser.last
      user.update(name: 'NEW')
    end

    expect(stats.query_counts).to be_empty
  end

  it 'records deletes and destroys' do
    user_1 = MockUser.create!
    user_2 = MockUser.create!
    user_3 = MockUser.create!

    post = MockPost.create!(mock_user: user_1)

    # For a later destroy_all
    MockPost.create!(mock_user: user_3)
    MockPost.create!(mock_user: user_3)
    MockPost.create!(mock_user: user_3)

    stats = described_class.instrument do
      user_1.destroy
      # This is implied from dependent destroy, so we're leaving the code here:
      # post.delete

      user_2.delete

      MockPost.destroy_all
    end

    expect(stats.query_counts).to eq('MockUser' => 2, 'MockPost' => 4)
  end
end
