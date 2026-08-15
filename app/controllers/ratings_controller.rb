# frozen_string_literal: true

class RatingsController < ApplicationController
  before_action :require_login!
  before_action :set_representative
  before_action :set_news_item

  def create
    @rating = Rating.find_or_initialize_by(news_item: @news_item, user: current_user)
    @rating.value = rating_params[:value]

    if @rating.save
      redirect_to representative_news_item_path(@representative, @news_item),
                  notice: 'Thanks for rating this article!'
    else
      redirect_to representative_news_item_path(@representative, @news_item),
                  alert: @rating.errors.full_messages.to_sentence
    end
  end

  private

  def set_representative
    @representative = Representative.find(params[:representative_id])
  end

  def set_news_item
    @news_item = NewsItem.find(params[:news_item_id])
  end

  def rating_params
    params.require(:rating).permit(:value)
  end
end
