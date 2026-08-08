# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewsItemsController do
  let!(:representative) do
    Representative.create!(
      name: 'Jane Doe',
      ocdid: '12345',
      title: 'Representative'
    )
  end

  let!(:news_item) do
    NewsItem.create!(
      representative: representative,
      title: 'Test News',
      link: 'https://example.com',
      description: 'Test description'
    )
  end

  describe 'GET index' do
    before do
      get :index, params: { representative_id: representative.id }
    end

    it 'returns a successful response' do
      expect(response).to be_successful
    end

    it 'assigns the representative news items' do
      expect(assigns(:news_items)).to include(news_item)
    end
  end

  describe 'GET show' do
    before do
      get :show,
          params: {
            representative_id: representative.id,
            id: news_item.id
          }
    end

    it 'returns a successful response' do
      expect(response).to be_successful
    end

    it 'assigns the requested news item' do
      expect(assigns(:news_item)).to eq(news_item)
    end
  end
end
