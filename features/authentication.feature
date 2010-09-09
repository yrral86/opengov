Feature: Authentication
  Scenario: User logs in
    Given I go to '/login'
    And I login with 'yrral86' and 'password'
    Then I should be logged in as 'yrral86'