Feature: Authentication
  In order to ensure information security
  As an administrator
  I want to require authentication for users

  Scenario: User logs in
    When I log out
    And I log in using 'test_user' and 'test_password'
    Then I am logged in as 'test_user'

  Scenario: User logs out
    Given I am logged in as 'test_user'
    When I go to '/logout'
    And I go to '/home'
    Then I am at '/login'

  Scenario: Create new user
    Given I am logged in as 'test_user'
    When I go to '/newuser'
    And I create a user 'newuser' with password 'newpassword'
    And I log in using 'newuser' and 'newpassword'
    Then I am logged in as 'newuser'

  Scenario: On login, user is redircted to last request
    Given I log out
    When I go to '/debug/test'
    And I log in using 'test_user' and 'test_password'
    Then I am at '/debug/test'
    And I am logged in as 'test_user'