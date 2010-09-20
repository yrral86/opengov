Feature: Map
  In order to find locations
  As an officer
  I want to see locations on a map and share those locations with other officers

  Scenario: Officer views map
    When I go to '/map'
    Then I should see 'It's a map!'
    And I should see 'Locations:'
