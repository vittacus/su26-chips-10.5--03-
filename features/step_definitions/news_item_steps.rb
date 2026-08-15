# frozen_string_literal: true

Given('a news article about {string} exists for {string}') do |title, representative_name|
  representative = Representative.find_by!(name: representative_name)

  @news_item = NewsItem.create!(
    title: title,
    link: 'https://example.com/article',
    description: 'A description of the article.',
    representative: representative,
    issue: 'Immigration'
  )
end

When('I visit the news article page') do
  visit representative_news_item_path(@news_item.representative, @news_item)
end
