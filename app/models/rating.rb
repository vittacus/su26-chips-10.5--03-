# frozen_string_literal: true

# == Schema Information
#
# Table name: ratings
#
#  id           :integer          not null, primary key
#  value        :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  news_item_id :integer          not null
#  user_id      :integer          not null
#
# Indexes
#
#  index_ratings_on_news_item_id              (news_item_id)
#  index_ratings_on_news_item_id_and_user_id  (news_item_id,user_id) UNIQUE
#  index_ratings_on_user_id                   (user_id)
#
# Foreign Keys
#
#  news_item_id  (news_item_id => news_items.id)
#  user_id       (user_id => users.id)
#
class Rating < ApplicationRecord
  belongs_to :news_item
  belongs_to :user

  validates :value, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :news_item_id, message: 'has already rated this article' }

  after_destroy :update_news_item_average_rating
  after_save :update_news_item_average_rating

  private

  def update_news_item_average_rating
    news_item.recalculate_average_rating!
  end
end
