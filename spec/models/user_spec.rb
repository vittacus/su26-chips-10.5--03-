# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  email      :string
#  first_name :string
#  last_name  :string
#  provider   :integer          not null
#  uid        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_uid_provider  (uid,provider) UNIQUE
#
require 'rails_helper'

RSpec.describe User do
  let(:user) do
    described_class.create!(
      first_name: 'Jane',
      last_name: 'Doe',
      provider: :google_oauth2,
      uid: 'uid-123'
    )
  end

  describe '#name' do
    it 'combines first and last name' do
      expect(user.name).to eq('Jane Doe')
    end
  end

  describe '#auth_provider' do
    it 'returns a human-readable provider name' do
      expect(user.auth_provider).to eq('Google')
    end
  end

  describe '.find_google_user' do
    it 'finds a user by google uid' do
      expect(described_class.find_google_user(user.uid)).to eq(user)
    end
  end

  describe '.find_github_user' do
    it 'returns nil when no matching github user exists' do
      expect(described_class.find_github_user('nonexistent-uid')).to be_nil
    end
  end
end
