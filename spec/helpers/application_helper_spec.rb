# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#auth_provider_path' do
    it 'maps google to the google_oauth2 auth path' do
      expect(helper.auth_provider_path('google')).to eq('/auth/google_oauth2')
    end

    it 'uses the provider name directly for other providers' do
      expect(helper.auth_provider_path('github')).to eq('/auth/github')
    end
  end

  describe '#login_enabled?' do
    it 'returns true in the development environment' do
      allow(Rails.env).to receive(:development?).and_return(true)
      expect(helper.login_enabled?('google')).to be true
    end

    it 'checks ENV credentials when not in development' do
      allow(Rails.env).to receive(:development?).and_return(false)
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('GOOGLE_CLIENT_ID', anything).and_return('id')
      allow(ENV).to receive(:fetch).with('GOOGLE_CLIENT_SECRET', anything).and_return('secret')
      expect(helper.login_enabled?('google')).to be true
    end
  end

  describe '.state_ids_by_name' do
    it 'maps state names to ids' do
      state = State.create!(
        name: 'Texas', symbol: 'TX', fips_code: 48, is_territory: 0,
        lat_min: 25.8, lat_max: 36.5, long_min: -106.6, long_max: -93.5
      )
      expect(described_class.state_ids_by_name).to include('Texas' => state.id)
    end
  end

  describe '.state_symbols_by_name' do
    it 'maps state names to symbols' do
      state = State.create!(
        name: 'Nevada', symbol: 'NV', fips_code: 32, is_territory: 0,
        lat_min: 35.0, lat_max: 42.0, long_min: -120.0, long_max: -114.0
      )
      expect(described_class.state_symbols_by_name).to include(state.name => state.symbol)
    end
  end
end
