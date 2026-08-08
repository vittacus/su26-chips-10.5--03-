# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event do
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

  let(:county) do
    County.create!(
      state: state,
      name: 'Santa Barbara County',
      fips_code: 83,
      fips_class: 'H1'
    )
  end

  def build_event(overrides={})
    Event.new(
      {
        name: 'Town Hall',
        county: county,
        start_time: 1.day.from_now,
        end_time: 2.days.from_now
      }.merge(overrides)
    )
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build_event).to be_valid
    end

    it 'requires a start_time' do
      event = build_event(start_time: nil)
      expect(event).not_to be_valid
      expect(event.errors[:start_time]).to be_present
    end

    it 'requires an end_time' do
      event = build_event(end_time: nil)
      expect(event).not_to be_valid
      expect(event.errors[:end_time]).to be_present
    end

    it 'requires start_time to be today or later' do
      event = build_event(start_time: 1.day.ago, end_time: 1.day.from_now)
      expect(event).not_to be_valid
      expect(event.errors[:start_time]).to include('must be after today')
    end

    it 'requires end_time to be on or after start_time' do
      event = build_event(start_time: 2.days.from_now, end_time: 1.day.from_now)
      expect(event).not_to be_valid
      expect(event.errors[:end_time]).to include('must be after start time')
    end
  end

  describe '#county_names_by_id' do
    # rubocop:disable RSpec/ExampleLength
    it 'returns a hash of county names to ids for the county\'s state' do
      other_county = County.create!(
        state: state, name: 'Ventura County', fips_code: 111, fips_class: 'H1'
      )
      event = build_event
      event.save!

      names = event.county_names_by_id

      expect(names).to include(county.name => county.id, other_county.name => other_county.id)
    end
    # rubocop:enable RSpec/ExampleLength

    it 'returns an empty hash when there is no county' do
      event = build_event(county: nil)
      expect(event.county_names_by_id).to eq({})
    end
  end
end
