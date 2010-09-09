Feature: Authentication
  Scenario: User logs in
    Given I log in using 'yrral86' and 'password'
    Then I am logged in as 'yrral86'

  Scenario: User logs out
    Given I log in using 'yrral86' and 'password'
    And I go to '/logout'
    And I go to '/home'
    Then I am at '/login'