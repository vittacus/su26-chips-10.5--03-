# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rating do
  let(:representative) do
    Representative.create!(
      name:  'Salud Carbajal',
      ocdid: 'ocd-division/country:us/state:ca/cd:24',
      title: 'representative'
    )
  end

  let(:news_item) do
    NewsItem.create!(
      title:           'New bill introduced',
      link:            'https://example.com/bill',
      description:     'A short description of the bill.',
      representative:  representative
    )
  end

  let(:user) do
    User.create!(
      email:      'rater@example.com',
      first_name: 'Rae',
      last_name:  'Ter',
      provider:   :developer,
      uid:        'rater-uid-1'
    )
  end

  let(:other_user) do
    User.create!(
      email:      'rater2@example.com',
      first_name: 'Rae',
      last_name:  'Ter Two',
      provider:   :developer,
      uid:        'rater-uid-2'
    )
  end

  def build_rating(overrides={})
    Rating.new({ value: 4, news_item: news_item, user: user }.merge(overrides))
  end

  describe 'associations' do
    it 'belongs to a news item' do
      expect(build_rating.news_item).to eq(news_item)
    end

    it 'belongs to a user' do
      expect(build_rating.user).to eq(user)
    end
  end

  describe 'validations' do
    it 'is valid with a value between 1 and 5' do
      expect(build_rating).to be_valid
    end

    it 'is invalid without a value' do
      expect(build_rating(value: nil)).not_to be_valid
    end

    it 'is invalid with a value below 1' do
      expect(build_rating(value: 0)).not_to be_valid
    end

    it 'is invalid with a value above 5' do
      expect(build_rating(value: 6)).not_to be_valid
    end

    it 'is invalid if the user already rated this news item' do
      build_rating.save!
      duplicate = build_rating

      expect(duplicate).not_to be_valid
    end

    it 'allows different users to rate the same news item' do
      build_rating(user: user).save!

      expect(build_rating(user: other_user)).to be_valid
    end
  end

  describe 'average rating recalculation' do
    it 'sets the news item average rating after a single rating is saved' do
      build_rating(value: 4).save!

      expect(news_item.reload.average_rating.to_f).to eq(4.0)
    end

    it 'averages multiple ratings from different users' do
      build_rating(user: user, value: 4).save!
      described_class.create!(value: 2, news_item: news_item, user: other_user)

      expect(news_item.reload.average_rating.to_f).to eq(3.0)
    end

    it 'updates the average when an existing rating changes' do
      rating = build_rating(value: 2)
      rating.save!

      rating.update!(value: 5)

      expect(news_item.reload.average_rating.to_f).to eq(5.0)
    end

    it 'recalculates the average after a rating is destroyed' do
      rating = build_rating(user: user, value: 4)
      rating.save!
      other_rating = described_class.create!(value: 2, news_item: news_item, user: other_user)

      other_rating.destroy

      expect(news_item.reload.average_rating.to_f).to eq(4.0)
    end

    it 'resets the average to 0 when the last rating is destroyed' do
      rating = build_rating(value: 4)
      rating.save!

      rating.destroy

      expect(news_item.reload.average_rating.to_f).to eq(0.0)
    end
  end
end
