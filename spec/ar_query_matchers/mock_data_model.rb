# frozen_string_literal: true

# @mission Infrastructure
# @team DEx

require 'active_record'

RSpec.shared_context('mock_data_model') do
  class ModelBase < ActiveRecord::Base
    self.abstract_class = true
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: ':memory:'
    )
  end

  let(:mock_user_class) do
    Class.new(ModelBase) do
      self.table_name = 'mock_users'

      def self.name
        'MockUser'
      end

      has_many :mock_posts, dependent: :destroy
    end
  end

  let(:mock_post_class) do
    Class.new(ModelBase) do
      self.table_name = 'mock_posts'

      def self.name
        'MockPost'
      end

      belongs_to :mock_user
    end
  end

  def create_tables
    unless ModelBase.connection.data_source_exists?(:mock_users)
      ModelBase.connection.create_table :mock_users do |t|
        t.text :name
      end
    end

    unless ModelBase.connection.data_source_exists?(:mock_posts)
      ModelBase.connection.create_table :mock_posts do |t|
        t.integer :mock_user_id
      end
    end
  end

  def drop_tables
    if ModelBase.connection.data_source_exists?(:mock_users)
      ModelBase.connection.drop_table(:mock_users)
    end

    if ModelBase.connection.data_source_exists?(:mock_posts)
      ModelBase.connection.drop_table(:mock_posts)
    end
  end

  before { create_tables }
  after { drop_tables }

  before do
    stub_const('MockUser', mock_user_class)
    stub_const('MockPost', mock_post_class)
  end
end
