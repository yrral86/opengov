Feature: Debug
  In order to aid in the development of the application
  As a developer
  I want to have a component for testing and debugging

  Scenario: Debug test url
    When I go to '/debug/test'
    Then I should see 'DebugController says hi!'

  Scenario: Display all people
    When I create a person 'TestFirstName TestLastName' via PersonLocator
    And I go to '/debug/people'
    Then I should see 'TestFirstName'
    And I should see 'TestLastName'
    And the HTML should contain 'table tr td a[href*="/personlocator/person"]'