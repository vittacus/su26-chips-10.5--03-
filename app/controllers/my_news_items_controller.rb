# frozen_string_literal: true

require 'net/http'
require 'json'

class MyNewsItemsController < ApplicationController
  before_action :require_login!

  before_action :set_representative
  before_action :set_representatives_list
  before_action :set_news_item, only: %i[edit update destroy]

  def new
    @news_item = NewsItem.new
  end

  def search
    @selected_representative =
      Representative.find(params[:news_item][:representative_id])

    @issue = params[:news_item][:issue]

    api_key = Rails.application.credentials[:CURRENTS_API_KEY]

    uri = URI('https://api.currentsapi.services/v1/search')
    uri.query = URI.encode_www_form(
      keywords: @issue,
      language: 'en',
      page_number: 1,
      page_size: 5,
      apiKey: api_key
    )

    response = Net::HTTP.get_response(uri)
    data = JSON.parse(response.body)

    Rails.logger.debug { "CURRENTS STATUS: #{response.code}" }
    Rails.logger.debug { "CURRENTS BODY: #{response.body}" }
    Rails.logger.debug { "ARTICLE COUNT: #{data.fetch('news', []).length}" }

    @articles = data.fetch('news', []).first(5)
  end

  def edit; end

  def create
    @news_item = NewsItem.new(news_item_params)
    if @news_item.save
      redirect_to representative_news_item_path(@representative, @news_item),
                  notice: 'News item was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @news_item.update(news_item_params)
      redirect_to representative_news_item_path(@representative, @news_item),
                  notice: 'News item was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @news_item.destroy
    redirect_to representative_news_items_path(@representative),
                notice: 'News was successfully destroyed.'
  end

  def save_article
    selected_index = params[:article_index]

    if selected_index.blank?
      redirect_back fallback_location: representative_news_items_path(@representative),
                    alert: 'Please select an article.'
      return
    end

    @news_item = build_selected_news_item(selected_index)

    if @news_item.save
      redirect_to representative_news_item_path(@representative, @news_item),
                  notice: 'News item was successfully created.'
    else
      redirect_back fallback_location: representative_news_items_path(@representative),
                    alert: 'Unable to save news item.'
    end
  end

  private

  def build_selected_news_item(selected_index)
    selected_article = params[:articles][selected_index]

    NewsItem.new(
      title: selected_article[:title],
      link: selected_article[:url],
      description: selected_article[:description],
      issue: params[:issue],
      representative: @representative
    )
  end

  def set_representative
    @representative = Representative.find(
      params[:representative_id]
    )
  end

  def set_representatives_list
    @representatives_list = Representative.all.map { |r| [r.name, r.id] }
  end

  def set_news_item
    @news_item = NewsItem.find(params[:id])
  end

  def news_item_params
    params.require(:news_item).permit(:title, :issue, :description, :link, :representative_id)
  end
end
