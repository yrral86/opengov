Feature: Authentication
  Scenario: User logs in
    Given I am logged out
    When I log in using 'test_user' and 'test_password'
    Then I am logged in as 'test_user'

  Scenario: User logs out
    When I go to '/logout'
    And I go to '/home'
    Then I am at '/login'