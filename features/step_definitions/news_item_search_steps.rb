# frozen_string_literal: true

Before('@news_item_search') do
  MyNewsItemsController.skip_before_action :require_login!
end

After('@news_item_search') do
  MyNewsItemsController.before_action :require_login!
end

Given('a representative named {string} exists') do |name|
  Representative.create!(
    name: name,
    ocdid: "test-#{name.parameterize}",
    title: 'representative'
  )
end

Given('I am logged in as a developer user') do
  visit login_path

  click_button 'Developer Login'

  fill_in 'Provider', with: 'developer'
  fill_in 'First name', with: 'Cucumber'
  fill_in 'Last name', with: 'Tester'
  fill_in 'Email', with: 'cucumber@example.com'

  click_button 'Sign In'
end

Given('CurrentsAPI returns news articles for {string}') do |_issue|
  articles = [
    {
      title: 'Immigration Article One',
      description: 'First immigration article description',
      url: 'https://example.com/article-one'
    },
    {
      title: 'Immigration Article Two',
      description: 'Second immigration article description',
      url: 'https://example.com/article-two'
    },
    {
      title: 'Immigration Article Three',
      description: 'Third immigration article description',
      url: 'https://example.com/article-three'
    },
    {
      title: 'Immigration Article Four',
      description: 'Fourth immigration article description',
      url: 'https://example.com/article-four'
    },
    {
      title: 'Immigration Article Five',
      description: 'Fifth immigration article description',
      url: 'https://example.com/article-five'
    }
  ]

  stub_request(:get, %r{api\.currentsapi\.services/v1/search})
    .to_return(
      status: 200,
      body: {
        status: 'ok',
        news: articles,
        page: 1
      }.to_json,
      headers: {
        'Content-Type' => 'application/json'
      }
    )
end

When('I visit the new news article page for {string}') do |name|
  representative = Representative.find_by!(name: name)
  visit representative_new_my_news_item_path(representative)
end

Then('I should see 5 selectable news articles') do
  expect(page).to have_field(
    'article_index',
    type: 'radio',
    count: 5
  )
end
