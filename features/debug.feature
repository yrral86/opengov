Feature: Debug
  In order to aid in the development of the application
  As a developer
  I want to have a component for testing and debugging

  Scenario: Debug test url
    When I go to '/debug/test'
    Then I should see 'DebugController says hi!'

  Scenario: Display all people
    Given I create a person 'first last' via PersonLocator
    When I go to '/debug/people'
    Then I should see 'first'
    And I should see 'last'