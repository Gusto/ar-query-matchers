# frozen_string_literal: true

# @mission Infrastructure
# @team DEx

require_relative './mock_data_model'

RSpec.describe ArQueryMatchers do
  include_context('mock_data_model')

  let!(:record) { MockUser.create! }

  def loads(amount)
    amount.times.each { MockUser.last }
  end

  def creates(amount)
    amount.times.each { MockUser.create! }
  end

  def updates(amount)
    amount.times.each { |i| record.update_attributes!(name: "name #{i}") }
  end

  describe 'not_load_any_models' do
    it 'succeeds' do
      expect do
        creates(1)
      end.to not_load_any_models
    end

    it 'fails' do
      expect do
        expect do
          loads(5)
        end.to not_load_any_models
      end.to raise_error(
        RSpec::Expectations::ExpectationNotMetError,
        /Expected ActiveRecord to not load any records, got {"MockUser"=>5}.*Where unexpected queries came from:/m
      )
    end
  end

  describe 'not_update_any_models' do
    it 'succeeds' do
      expect do
        loads(5)
        creates(5)
      end.to not_update_any_models
    end

    it 'fails' do
      expect do
        expect do
          updates(5)
        end.to not_update_any_models
      end.to raise_error(
        RSpec::Expectations::ExpectationNotMetError,
        /Expected ActiveRecord to not update any records, got {"MockUser"=>5}.*Where unexpected queries came from:/m
      )
    end
  end

  describe 'not_create_any_models' do
    it 'succeeds' do
      expect do
        loads(1)
        updates(1)
      end.to not_create_any_models
    end

    it 'fails' do
      expect do
        expect do
          creates(5)
        end.to not_create_any_models
      end.to raise_error(
        RSpec::Expectations::ExpectationNotMetError,
        /Expected ActiveRecord to not create any records, got {"MockUser"=>5}.*Where unexpected queries came from:/m
      )
    end
  end

  describe 'only_update_models' do
    it 'succeeds' do
      expect do
        updates(5)
        loads(1)
        creates(1)
      end.to only_update_models('MockUser' => 5)
    end

    it 'fails' do
      expect do
        expect do
          updates(2)
        end.to only_update_models('MockUser' => 3)
      end.to raise_error(
        RSpec::Expectations::ExpectationNotMetError,
        /Expected ActiveRecord to update {"MockUser"=>3}, got {"MockUser"=>2}.*Where unexpected queries came from:/m
      )
    end
  end

  describe 'only_create_models' do
    it 'succeeds' do
      expect do
        updates(1)
        loads(1)
        creates(5)
      end.to only_create_models('MockUser' => 5)
    end

    it 'fails' do
      expect do
        expect do
          creates(2)
        end.to only_create_models('MockUser' => 3)
      end.to raise_error(
        RSpec::Expectations::ExpectationNotMetError,
        /Expected ActiveRecord to create {"MockUser"=>3}, got {"MockUser"=>2}.*Where unexpected queries came from:/m
      )
    end
  end

  describe 'only_load_models' do
    it 'succeeds' do
      expect do
        updates(1)
        loads(5)
        creates(1)
      end.to only_load_models('MockUser' => 5)
    end

    it 'fails' do
      expect do
        expect do
          loads(2)
        end.to only_load_models('MockUser' => 3)
      end.to raise_error(
        RSpec::Expectations::ExpectationNotMetError,
        /Expected ActiveRecord to load {"MockUser"=>3}, got {"MockUser"=>2}.*Where unexpected queries came from:/m
      )
    end
  end
end
