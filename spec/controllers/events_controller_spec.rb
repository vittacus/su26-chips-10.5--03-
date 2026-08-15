# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsController do
  let(:state) do
    State.create!(
      name: 'California', symbol: 'CA', fips_code: 6, is_territory: 0,
      lat_min: 32.5, lat_max: 42.0, long_min: -124.4, long_max: -114.1
    )
  end

  let(:other_state) do
    State.create!(
      name: 'Nevada', symbol: 'NV', fips_code: 32, is_territory: 0,
      lat_min: 35.0, lat_max: 42.0, long_min: -120.0, long_max: -114.0
    )
  end

  let(:county) do
    County.create!(state: state, name: 'Santa Barbara County', fips_code: 83, fips_class: 'H1')
  end

  let(:other_county) do
    County.create!(state: state, name: 'Ventura County', fips_code: 111, fips_class: 'H1')
  end

  let(:out_of_state_county) do
    County.create!(state: other_state, name: 'Clark County', fips_code: 3, fips_class: 'H1')
  end

  let!(:event) do
    Event.create!(name: 'Town Hall', county: county, start_time: 1.day.from_now, end_time: 2.days.from_now)
  end

  let!(:other_event) do
    Event.create!(name: 'Rally', county: other_county, start_time: 1.day.from_now, end_time: 2.days.from_now)
  end

  let!(:out_of_state_event) do
    Event.create!(name: 'Fundraiser', county: out_of_state_county, start_time: 1.day.from_now,
                  end_time: 2.days.from_now)
  end

  describe 'GET index' do
    context 'without a filter' do
      before { get :index }

      it 'returns a successful response' do
        expect(response).to be_successful
      end

      it 'assigns all events' do
        expect(assigns(:events)).to include(event, other_event, out_of_state_event)
      end
    end

    context 'when filtered by state only' do
      before { get :index, params: { 'filter-by' => 'state-only', 'state' => state.symbol } }

      it 'only includes events in that state' do
        expect(assigns(:events)).to contain_exactly(event, other_event)
      end
    end

    context 'when filtered by state and county' do
      before do
        get :index, params: { 'filter-by' => 'county', 'state' => state.symbol, 'county' => county.fips_code }
      end

      it 'only includes events in that county' do
        expect(assigns(:events)).to contain_exactly(event)
      end
    end
  end

  describe 'GET show' do
    before { get :show, params: { id: event.id } }

    it 'returns a successful response' do
      expect(response).to be_successful
    end

    it 'assigns the requested event' do
      expect(assigns(:event)).to eq(event)
    end
  end
end
