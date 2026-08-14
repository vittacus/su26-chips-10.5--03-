# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MyNewsItems' do
  let!(:representative) do
    Representative.create!(
      name: 'Lateefah Simon',
      ocdid: '12345',
      title: 'representative'
    )
  end

  let!(:other_representative) do
    Representative.create!(
      name: 'Eleanor Norton',
      ocdid: '67890',
      title: 'representative'
    )
  end

  before do
    MyNewsItemsController.skip_before_action :require_login!

    stub_request(:get, /api\.currentsapi\.services/)
      .to_return(
        status: 200,
        body: {
          status: 'ok',
          news: [
            {
              title: 'Test Article',
              description: 'Test Description',
              url: 'https://example.com/article'
            }
          ]
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  after do
    MyNewsItemsController.before_action :require_login!
  end

  describe 'GET /representatives/:representative_id/my_news_item/new' do
    before do
      get representative_new_my_news_item_path(representative)
    end

    it 'returns a successful response' do
      expect(response).to have_http_status(:ok)
    end

    it 'shows the representative and issue selectors' do
      expect(response.body).to include('Representative')
      expect(response.body).to include('Issue')
      expect(response.body).to include('Search')
    end

    it 'includes representatives in the dropdown' do
      expect(response.body).to include(representative.name)
      expect(response.body).to include(other_representative.name)
    end

    it 'includes available issues in the dropdown' do
      expect(response.body).to include('Immigration')
      expect(response.body).to include('Climate Change')
      expect(response.body).to include('Tax Reform')
    end
  end

  describe 'GET /representatives/:representative_id/my_news_item/search' do
    let(:search_params) do
      {
        news_item: {
          representative_id: representative.id,
          issue: 'Immigration'
        }
      }
    end

    before do
      get representative_search_my_news_item_path(representative),
          params: search_params
    end

    it 'returns a successful response' do
      expect(response).to have_http_status(:ok)
    end

    it 'shows the selected representative' do
      expect(response.body).to include('Lateefah Simon')
    end

    it 'shows the selected issue as plain text' do
      expect(response.body).to include('Immigration')
    end

    it 'queries CurrentsAPI using the selected issue' do
      expect(currents_request).to have_been_made.once
    end

    it 'shows returned article data' do
      expect(response.body).to include('Test Article')
      expect(response.body).to include('Test Description')
      expect(response.body).to include('https://example.com/article')
    end
  end

  def currents_request
    a_request(:get, /api\.currentsapi\.services/)
      .with { |request| request.uri.query.include?('Immigration') }
  end
end
