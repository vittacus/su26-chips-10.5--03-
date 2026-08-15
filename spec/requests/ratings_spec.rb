# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Ratings' do
  let!(:representative) do
    Representative.create!(name: 'Lateefah Simon', ocdid: '12345', title: 'representative')
  end

  let!(:news_item) do
    NewsItem.create!(
      title: 'Bill introduced',
      link:  'https://example.com/bill',
      representative: representative
    )
  end

  let!(:user) do
    User.create!(email: 'rater@example.com', first_name: 'Rae', last_name: 'Ter', provider: :developer, uid: 'rater-uid')
  end

  describe 'POST /representatives/:representative_id/news_items/:news_item_id/ratings' do
    context 'when not logged in' do
      it 'redirects to the login page' do
        post representative_news_item_ratings_path(representative, news_item), params: { rating: { value: 5 } }

        expect(response).to redirect_to(login_path)
      end

      it 'does not create a rating' do
        expect do
          post representative_news_item_ratings_path(representative, news_item), params: { rating: { value: 5 } }
        end.not_to change(Rating, :count)
      end
    end

    context 'when logged in' do
      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      end

      it 'creates a rating for the news item' do
        expect do
          post representative_news_item_ratings_path(representative, news_item), params: { rating: { value: 5 } }
        end.to change(Rating, :count).by(1)
      end

      it 'redirects back to the news item page' do
        post representative_news_item_ratings_path(representative, news_item), params: { rating: { value: 5 } }

        expect(response).to redirect_to(representative_news_item_path(representative, news_item))
      end

      it 'updates the news item average rating' do
        post representative_news_item_ratings_path(representative, news_item), params: { rating: { value: 5 } }

        expect(news_item.reload.average_rating.to_f).to eq(5.0)
      end

      it 'updates the existing rating instead of creating a duplicate when the user rates again' do
        post representative_news_item_ratings_path(representative, news_item), params: { rating: { value: 2 } }

        expect do
          post representative_news_item_ratings_path(representative, news_item), params: { rating: { value: 5 } }
        end.not_to change(Rating, :count)

        expect(Rating.find_by(news_item: news_item, user: user).value).to eq(5)
      end

      it 'rejects an out-of-range value' do
        post representative_news_item_ratings_path(representative, news_item), params: { rating: { value: 9 } }

        expect(Rating.count).to eq(0)
      end
    end
  end
end