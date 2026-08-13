# frozen_string_literal: true

# == Schema Information
#
# Table name: news_items
#
#  id                :integer          not null, primary key
#  description       :text
#  issue             :string
#  link              :string           not null
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  representative_id :integer          not null
#
# Indexes
#
#  index_news_items_on_representative_id  (representative_id)
#
require 'rails_helper'

RSpec.describe NewsItem do
  let(:representative) do
    Representative.create!(
      name: 'Salud Carbajal',
      ocdid: 'ocd-division/country:us/state:ca/cd:24',
      title: 'representative'
    )
  end

  def build_news_item(overrides={})
    NewsItem.new(
      {
        title: 'New bill introduced',
        link: 'https://example.com/bill',
        description: 'A short description of the bill.',
        representative: representative
      }.merge(overrides)
    )
  end

  describe 'associations' do
    it 'belongs to a representative' do
      news_item = build_news_item
      expect(news_item.representative).to eq(representative)
    end

    it 'is invalid without a representative' do
      news_item = build_news_item(representative: nil)
      expect(news_item).not_to be_valid
    end
  end

  describe '.find_for' do
    it 'finds a news item by representative_id' do
      news_item = build_news_item
      news_item.save!

      found = described_class.find_for(representative.id)

      expect(found).to eq(news_item)
    end

    it 'returns nil when no news item exists for the representative' do
      other_representative = Representative.create!(
        name: 'Alejandro Padilla', ocdid: 'ocd-division/country:us/state:ca', title: 'senator'
      )
      expect(described_class.find_for(other_representative.id)).to be_nil
    end
  end
end
