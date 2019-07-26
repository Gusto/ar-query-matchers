# frozen_string_literal: true

# @mission Infrastructure
# @team DEx

require_relative '../mock_data_model'

RSpec.describe ArQueryMatchers::Queries::LoadCounter do
  include_context('mock_data_model')

  it 'does not include creates or updates' do
    stats = described_class.instrument do
      user = MockUser.create!
      user.update_attributes!(name: 'a name')
    end

    expect(stats.query_counts).to be_empty
  end

  it 'evaluating a has many counts as a single query' do
    user = MockUser.create!
    MockPost.create!(mock_user: user)
    MockPost.create!(mock_user: user)

    stats = described_class.instrument do
      expect(user.mock_posts.to_a.size).to eq 2
    end

    expect(stats.query_counts).to eq('MockPost' => 1)
  end

  it 'records individual finds' do
    user = MockUser.create!
    stats = described_class.instrument do
      MockUser.find(user.id)
      MockUser.find(user.id)
      MockUser.find(user.id)
    end

    expect(stats.query_counts).to eq('MockUser' => 3)
  end

  it 'n+1ing' do
    user1 = MockUser.create!(name: '1')
    user2 = MockUser.create!(name: '2')
    user3 = MockUser.create!(name: '3')

    MockPost.create!(mock_user: user1)
    MockPost.create!(mock_user: user1)
    MockPost.create!(mock_user: user2)
    MockPost.create!(mock_user: user2)
    MockPost.create!(mock_user: user3)
    MockPost.create!(mock_user: user3)

    stats = described_class.instrument do
      MockUser.all.map(&:mock_posts).map(&:to_a)
    end

    expect(stats.query_counts).to eq('MockUser' => 1, 'MockPost' => 3)
  end

  it 'includes reduce n+1s' do
    user1 = MockUser.create!(name: '1')
    user2 = MockUser.create!(name: '2')
    user3 = MockUser.create!(name: '3')

    MockPost.create!(mock_user: user1)
    MockPost.create!(mock_user: user1)
    MockPost.create!(mock_user: user2)
    MockPost.create!(mock_user: user2)
    MockPost.create!(mock_user: user3)
    MockPost.create!(mock_user: user3)

    stats = described_class.instrument do
      MockUser.includes(:mock_posts).all.map(&:mock_posts).map(&:to_a)
    end

    expect(stats.query_counts).to eq('MockUser' => 1, 'MockPost' => 1)
  end
end
