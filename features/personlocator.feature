Feature: PersonLocator
  In order to have a place to test model crud functionality
  As a developer
  I want to have a component that utiliizes it

  Scenario: View list
    Given there are people records in PersonLocator
    When I go to '/personlocator/person'
    Then there should be one more row than 'PersonLocator::Person' records