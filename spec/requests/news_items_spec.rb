# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'NewsItems' do
  let(:representative) do
    Representative.create!(name: 'Salud Carbajal', ocdid: 'ocd-news-1', title: 'representative')
  end

  let(:news_item) do
    representative.news_items.create!(
      title: 'New bill introduced', link: 'https://example.com/bill'
    )
  end

  describe 'GET /representatives/:representative_id/news_items' do
    it 'lists news items for that representative' do
      news_item
      get "/representatives/#{representative.id}/news_items"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(news_item.title)
    end
  end

  describe 'GET /representatives/:representative_id/news_items/:id' do
    it 'shows a single news item' do
      get "/representatives/#{representative.id}/news_items/#{news_item.id}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(news_item.title)
    end
  end
end
