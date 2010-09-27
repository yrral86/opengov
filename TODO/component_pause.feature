Feature: Pause and resume components
  As an administrator
  I want to pause (sig STOP) a component
  And resume (sig CONT) stopped components
   (need to close db connections?)
   (does the answer change with connection pools?)

  Scenario Outline: stop a component
    Given '<component>' is running
    Given '<component>' is registered
    When I send the manager 'pause' for '<component>'
    Then '<component>' is paused

  Scenario Outline: resume a stopped component
    Given '<component>' is registered
    And '<component>' is paused
    When I send the manager 'resume' for '<component>'
    Then '<component>' is running

  Scenario Outline: auto pause
    Given components can pause and resume in less than a second
    When a component has not been used in a while
    Then the component can choose to have the manager pause it

  Scenario Outline: auto resume
    Given components can pause and resule in less than a second
    When a component is paused
    And a requeset arrives for that component
    Or another component wants to use the paused component
    The component is woken up by the manager
     (what about component -> component access... also need to wake up then)
     (subclass DRbObject here...)
     (clients don't use Service.get except for Manager...)
     (manager gives them an OurObject < DRbObject instance)

