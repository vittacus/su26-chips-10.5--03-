# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserController do
  let(:user) do
    User.create!(
      email:      'profile@example.com',
      first_name: 'Pro',
      last_name:  'File',
      provider:   :developer,
      uid:        'profile-uid'
    )
  end

  describe 'GET profile' do
    context 'when logged in' do
      before do
        session[:user_id] = user.id
        get :profile
      end

      it 'returns a successful response' do
        expect(response).to be_successful
      end

      it 'assigns the current user' do
        expect(assigns(:user)).to eq(user)
      end
    end

    context 'when not logged in' do
      before { get :profile }

      it 'redirects to the login page' do
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
