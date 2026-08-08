# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RepresentativesController do
  let!(:representative) do
    Representative.create!(
      name: 'Jane Doe',
      ocdid: '12345',
      title: 'Representative'
    )
  end

  describe 'GET index' do
    before { get :index }

    it 'returns a successful response' do
      expect(response).to be_successful
    end

    it 'assigns all representatives' do
      expect(assigns(:representatives)).to include(representative)
    end
  end

  describe 'GET show' do
    before { get :show, params: { id: representative.id } }

    it 'returns a successful response' do
      expect(response).to be_successful
    end

    it 'assigns the requested representative' do
      expect(assigns(:representative)).to eq(representative)
    end
  end
end
