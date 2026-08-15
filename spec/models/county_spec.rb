# frozen_string_literal: true

require 'rails_helper'

RSpec.describe County do
  let(:state) do
    State.create!(
      name: 'California',
      symbol: 'CA',
      fips_code: 6,
      is_territory: 0,
      lat_min: 32.5,
      lat_max: 42.0,
      long_min: -124.4,
      long_max: -114.1
    )
  end

  def build_county(overrides={})
    County.new({ state: state, name: 'Santa Barbara County', fips_code: 83, fips_class: 'H1' }.merge(overrides))
  end

  describe 'associations' do
    it 'belongs to a state' do
      expect(build_county.state).to eq(state)
    end
  end

  describe '#std_fips_code' do
    it 'pads a single-digit fips code to three digits' do
      expect(build_county(fips_code: 3).std_fips_code).to eq('003')
    end

    it 'pads a two-digit fips code to three digits' do
      expect(build_county(fips_code: 83).std_fips_code).to eq('083')
    end

    it 'does not pad a three-digit fips code' do
      expect(build_county(fips_code: 123).std_fips_code).to eq('123')
    end
  end
end
