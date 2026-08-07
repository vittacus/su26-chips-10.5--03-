# frozen_string_literal: true

# == Schema Information
#
# Table name: representatives
#
#  id           :integer          not null, primary key
#  address      :string
#  birthday     :string
#  contact_form :string
#  facebook     :string
#  gender       :string
#  name         :string
#  ocdid        :string
#  party        :string
#  phone        :string
#  photo_url    :string
#  title        :string
#  twitter      :string
#  website      :string
#  youtube      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  bioguide_id  :string
#

class Representative < ApplicationRecord
  has_many :news_items, dependent: :delete_all

  # Review the Geocodio docs
  # https://www.geocod.io/docs/#congressional-districts
  def self.geocodio_search(query)
    geocodio_api_key = ENV.fetch(
      'GEOCODIO_API_KEY',
      Rails.application.credentials[:GEOCODIO_API_KEY]
    )

    raise ArgumentError, 'Missing GEOCODIO_API_KEY' if geocodio_api_key.blank?

    geocodio = Geocodio::Gem.new(geocodio_api_key)
    geocodio.geocode(query, ['cd'])
  end

  def self.civic_api_to_representative_params(rep_info)
    reps = []

    response = rep_info['results'][0]['response']
    fields = response['results'][0]['fields']
    legislators = fields['congressional_districts'][0]['current_legislators']

    legislators.each do |official|
      official['name'] =
        "#{official.dig('bio', 'first_name')} #{official.dig('bio', 'last_name')}"

      title = official['type']
      ocdid = official.dig('references', 'govtrack_id')

      reps << Representative.find_rep(
        official,
        ocdid: ocdid,
        title: title
      )
    end

    reps
  end

  def self.find_rep(official, title: '', ocdid: '')
    Representative.create(
      {
        name: official['name'],
        ocdid: ocdid,
        title: title
      }.merge(geocodio_details(official))
    )
  end

  def self.geocodio_details(official)
    {
      party: official.dig('bio', 'party'),
      birthday: official.dig('bio', 'birthday'),
      gender: official.dig('bio', 'gender'),
      address: official.dig('contact', 'address'),
      phone: official.dig('contact', 'phone'),
      website: official.dig('contact', 'url'),
      contact_form: official.dig('contact', 'contact_form'),
      twitter: official.dig('social', 'twitter'),
      facebook: official.dig('social', 'facebook'),
      youtube: official.dig('social', 'youtube'),
      bioguide_id: official.dig('references', 'bioguide_id'),
      photo_url: photo_url_for(official)
    }
  end

  def self.photo_url_for(official)
    bioguide_id = official.dig('references', 'bioguide_id')
    return if bioguide_id.blank?

    "https://bioguide.congress.gov/bioguide/photo/#{bioguide_id[0]}/#{bioguide_id}.jpg"
  end

  def update_from_geocodio(official)
    update!(
      {
        title: official['type'],
        ocdid: official.dig('references', 'govtrack_id')
      }.merge(self.class.geocodio_details(official))
    )

    self
  end
end
