# frozen_string_literal: true

# You should add your own steps and support functions here.

# These steps here are scaffolds, which might be useful.

Given /^I am logged in via (github|google|developer) as (".*")/i do |provider, _data|
  # This is just a start. You may want to setup Omniauth differently.
  # Look up Omniauth.test_mode
  page.find_link(text: "#{provider.capitalize} Login")
end

# Suggest Steps that Interact with the Map.
# The Map is rendered as a bunch of SVG elements, which clock can
# 'click' on and the user will be taken to the hopefully right page.
# You should inspect the HTML generated in the browser.
# As a hint you should be able to write some JavaScript
# Example JS: let ca = $('path[data-state-symbol="CA"]')
# This will find all elements based on those data attributes.

# <path class="actionmap-view-region" d="" tabindex="0" data-state-name="California"
#    data-state-fips-code="06" data-state-symbol="CA"></path>

Then /I click the state "(\w\w)"/i do |state|
  # Find the element, assert it exists.
  # then 'fake click' it by directly visiting the URL
  # IDEALLY we could call .click on the element directly, but
  # this currently errors in Chrome with SVG elements / doesn't navigate.
  expect(page).to have_css("path[data-state-symbol='#{state}']")
  visit state_map_path(state)
end

Then /I click the county "(.*)"/i do |county_name|
  expect(page).to have_css("path[data-county-name='#{county_name}']")
  state_symbol = current_url[%r{/state/(\w\w)}, 1]
  query = "#{county_name}, #{state_symbol}"
  visit "/search/#{ERB::Util.url_encode(query)}"
end

Then /I click the county with FIPS Code "(.*)"/i do |fips_code|
  # Same as above, you might find this helpful.
end

Then /I should see (\d+) (?:states|counties)/i do |count|
  # How many counties should the map render
  # You might use this as a check that the right number of elements are rendered.
end

Given /^the following representatives exist for "([^"]*)":$/ do |_location, table|
  legislators = table.hashes.map do |row|
    first, *rest = row['name'].split
    {
      'type' => row['title'],
      'bio' => { 'first_name' => first, 'last_name' => rest.join(' '), 'party' => 'Democrat' },
      'contact' => { 'url' => 'https://example.com', 'address' => '123 Main St', 'phone' => '555-555-5555' },
      'social' => {},
      'references' => { 'bioguide_id' => "B#{rand(100_000)}", 'govtrack_id' => rand(100_000).to_s }
    }
  end

  body = {
    'results' => [{
      'response' => {
        'results' => [{
          'fields' => {
            'congressional_districts' => [{
              'name' => 'Congressional District 1',
              'district_number' => 1,
              'ocd_id' => 'ocd-division/country:us/state:ca/cd:1',
              'current_legislators' => legislators
            }]
          }
        }]
      }
    }]
  }.to_json

  stub_request(:post, /api\.geocod\.io/).to_return(
    status: 200,
    body: body,
    headers: { 'Content-Type' => 'application/json' }
  )
end
