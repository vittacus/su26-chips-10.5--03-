# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MyEventsController do
  let(:state) do
    State.create!(
      name: 'California', symbol: 'CA', fips_code: 6, is_territory: 0,
      lat_min: 32.5, lat_max: 42.0, long_min: -124.4, long_max: -114.1
    )
  end

  let(:county) do
    County.create!(state: state, name: 'Santa Barbara County', fips_code: 83, fips_class: 'H1')
  end

  let(:user) do
    User.create!(
      email: 'organizer@example.com', first_name: 'Org', last_name: 'Nizer',
      provider: :developer, uid: 'organizer-uid'
    )
  end

  let(:valid_params) do
    {
      event: {
        name: 'Town Hall',
        county_id: county.id,
        description: 'Come one, come all.',
        start_time: 1.day.from_now,
        end_time: 2.days.from_now
      }
    }
  end

  describe 'access control' do
    it 'redirects to login when not logged in' do
      get :new
      expect(response).to redirect_to(login_path)
    end
  end

  context 'when logged in' do
    before { session[:user_id] = user.id }

    describe 'GET new' do
      before { get :new }

      it 'returns a successful response' do
        expect(response).to be_successful
      end

      it 'assigns a new event' do
        expect(assigns(:event)).to be_a_new(Event)
      end
    end

    describe 'POST create with valid params' do
      it 'creates a new event' do
        expect { post :create, params: valid_params }.to change(Event, :count).by(1)
      end

      it 'redirects to the events list' do
        post :create, params: valid_params
        expect(response).to redirect_to(events_path)
      end
    end

    describe 'POST create with invalid params' do
      it 'does not create an event' do
        expect { post :create, params: { event: { name: '' } } }.not_to change(Event, :count)
      end

      it 're-renders the new form' do
        post :create, params: { event: { name: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe 'GET edit' do
      let!(:event) do
        Event.create!(name: 'Town Hall', county: county, start_time: 1.day.from_now, end_time: 2.days.from_now)
      end

      before { get :edit, params: { id: event.id } }

      it 'returns a successful response' do
        expect(response).to be_successful
      end

      it 'assigns the requested event' do
        expect(assigns(:event)).to eq(event)
      end
    end

    describe 'PATCH update' do
      let!(:event) do
        Event.create!(name: 'Town Hall', county: county, start_time: 1.day.from_now, end_time: 2.days.from_now)
      end

      it 'updates the event' do
        patch :update, params: { id: event.id, event: { name: 'Updated Name' } }
        expect(event.reload.name).to eq('Updated Name')
      end

      it 'redirects to the events list' do
        patch :update, params: { id: event.id, event: { name: 'Updated Name' } }
        expect(response).to redirect_to(events_path)
      end
    end

    describe 'DELETE destroy' do
      let!(:event) do
        Event.create!(name: 'Town Hall', county: county, start_time: 1.day.from_now, end_time: 2.days.from_now)
      end

      it 'destroys the event' do
        expect { delete :destroy, params: { id: event.id } }.to change(Event, :count).by(-1)
      end

      it 'redirects to the events list' do
        delete :destroy, params: { id: event.id }
        expect(response).to redirect_to(events_url)
      end
    end
  end
end
