# frozen_string_literal: true

class AddAverageRatingToNewsItems < ActiveRecord::Migration[7.2]
  def change
    add_column :news_items, :average_rating, :decimal, precision: 3, scale: 2, default: 0.0, null: false
  end
end
