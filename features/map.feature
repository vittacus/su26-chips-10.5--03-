Feature: ActionMap Shows State and County Maps

Scenario: Navigating States and counties
  Given I am on the homepage
  Then I should see "National Map"
  When I click the state "CA"
  Then I should see "California"
  And I should be on the state page for "CA"

Scenario: Clicking a county navigates to that county's representatives
  Given the following representatives exist for "Santa Barbara County, CA":
    | name              | title          |
    | Salud Carbajal     | representative |
    | Alejandro Padilla  | senator        |
  When I am on the state page for "CA"
  And I click the county "Santa Barbara County"
  Then I should see "Salud Carbajal"
  And I should see "Alejandro Padilla"

Scenario: Visiting a county's search URL directly returns representatives
  Given the following representatives exist for "Santa Barbara County, CA":
    | name           | title          |
    | Salud Carbajal | representative |
  When I go to the search results page for "Santa Barbara County, CA"
  Then I should see "Salud Carbajal"