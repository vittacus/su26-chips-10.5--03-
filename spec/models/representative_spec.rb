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
require 'rails_helper'

# This file is a stub.
# You should add your own test cases.
# We recommend creating a file for each model in the database.

# RSpec.describe Representative do
# end

RSpec.describe Representative do
  describe '.civic_api_to_representative_params' do
    let(:rep_info) do
      {
        'results' => [
          {
            'response' => {
              'results' => [
                {
                  'fields' => {
                    'congressional_districts' => [
                      {
                        'current_legislators' => [
                          {
                            'bio' => {
                              'first_name' => 'Jane',
                              'last_name' => 'Doe'
                            },
                            'type' => 'representative',
                            'references' => {
                              'govtrack_id' => '12345',
                              'bioguide_id' => 'D000001'
                            }
                          }
                        ]
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

    let!(:existing_rep) do
      described_class.create!(
        name: 'Jane Doe',
        ocdid: '12345',
        title: 'representative'
      )
    end

    it 'does not create a duplicate representative when one already exists' do
      expect do
        described_class.civic_api_to_representative_params(rep_info)
      end.not_to change(described_class, :count)
    end

    it 'creates a representative when one does not already exist' do
      existing_rep.destroy!

      expect do
        described_class.civic_api_to_representative_params(rep_info)
      end.to change(described_class, :count).by(1)
    end
  end
end
