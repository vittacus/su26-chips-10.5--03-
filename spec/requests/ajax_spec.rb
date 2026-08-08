# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Ajax' do
  describe 'GET /ajax/state/:state_symbol' do
    # rubocop:disable RSpec/ExampleLength
    it 'returns the counties for that state as json' do
      state = State.create!(
        name: 'Oregon', symbol: 'OR', fips_code: 41, is_territory: 0,
        lat_min: 42.0, lat_max: 46.3, long_min: -124.6, long_max: -116.5
      )
      county = state.counties.create!(name: 'Multnomah County', fips_code: 51, fips_class: 'H1')

      get "/ajax/state/#{state.symbol}"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.first['name']).to eq(county.name)
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
