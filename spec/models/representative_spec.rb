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

# This file is a stub.
# You should add your own test cases.
# We recommend creating a file for each model in the database.

# RSpec.describe Representative do
# end

require 'rails_helper'

RSpec.describe Representative do
  describe '.geocodio_search' do
    subject(:search) { described_class.geocodio_search('Los Angeles, CA') }

    before do
      ENV['GEOCODIO_API_KEY'] = 'test-api-key'

      stub_request(:post, /api\.geocod\.io/).to_return(
        status: 200,
        body: { results: [] }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    after do
      ENV.delete('GEOCODIO_API_KEY')
    end

    it 'calls the Geocodio API' do
      search
      expect(a_request(:post, /api\.geocod\.io/)).to have_been_made.once
    end
  end

  describe '.civic_api_to_representative_params' do
    subject(:representative) do
      described_class.civic_api_to_representative_params(response).first
    end

    let(:response) do
      {
        'results' => [
          {
            'response' => {
              'results' => [
                {
                  'fields' => {
                    'congressional_districts' => [
                      {
                        'current_legislators' => legislators
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
    end

    context 'with complete representative data' do
      let(:legislators) do
        [
          {
            'type' => 'representative',
            'bio' => {
              'first_name' => 'Jane',
              'last_name' => 'Doe',
              'party' => 'Democrat'
            },
            'contact' => {
              'phone' => '202-555-1234'
            },
            'social' => {},
            'references' => {
              'bioguide_id' => 'D000001',
              'govtrack_id' => '123456'
            }
          }
        ]
      end

      it 'creates the representative' do
        expect(representative).to have_attributes(name: 'Jane Doe', party: 'Democrat',
                                                  phone: '202-555-1234', bioguide_id: 'D000001')
      end
    end

    context 'with missing optional fields' do
      let(:legislators) do
        [
          {
            'type' => 'representative',
            'bio' => {
              'first_name' => 'John',
              'last_name' => 'Smith'
            },
            'contact' => {},
            'social' => {},
            'references' => {}
          }
        ]
      end

      it 'handles missing values without crashing' do
        expect(representative).to have_attributes(name: 'John Smith', party: nil,
                                                  phone: nil, photo_url: nil)
      end
    end
  end
end
