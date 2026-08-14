@news_item_search
Feature: Search for news articles by representative and issue
  As a user
  I want to choose a representative and an issue
  So that I can search for relevant news articles

  Background:
    Given a representative named "Lateefah Simon" exists
    And CurrentsAPI returns news articles for "Immigration"

  Scenario: The new news article page shows representative and issue selectors
    When I visit the new news article page for "Lateefah Simon"
    Then I should see "Search for a News Article"
    And I should see "Representative"
    And I should see "Issue"
    And I should see "Search"

  Scenario: A user searches for articles using a representative and issue
    When I visit the new news article page for "Lateefah Simon"
    And I select "Lateefah Simon" from "Representative"
    And I select "Immigration" from "Issue"
    And I press "Search"
    Then I should see "Edit News Item"
    And I should see "Lateefah Simon"
    And I should see "Immigration"
    And I should see "Immigration Article One"
    And I should see "Immigration Article Two"
    And I should see "https://example.com/article-one"
    And I should see "First immigration article description"

  Scenario: The search result page displays selectable articles
    When I visit the new news article page for "Lateefah Simon"
    And I select "Lateefah Simon" from "Representative"
    And I select "Immigration" from "Issue"
    And I press "Search"
    Then I should see 5 selectable news articles
