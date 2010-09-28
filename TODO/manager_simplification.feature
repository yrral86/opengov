Feature: Simplified Manager, Manager API
  As a developer
  In order to simplify the code for Manager users/consumers
  And define a Manager API for three consumer types
   (Components get information about other components via Manager)
   (RequestRouter gets routes from Manager)
   (Admin (via ./control.rb) sends Manager commands for components)

  Scenario Outline: define a Manager API for three consumer types
    When '<consumer>' is accessing the Manager
    Then the method '<API>' is available
    And '<others>' can not call '<API>'

    Scenarios: API
      | API                  | consumer      | others                  |
      | available_components | Component     | Admin,RequestRouter     |
      | available_models     | Component     | Admin,RequestRouter     |
      | available_types      | Component     | Admin,RequestRouter     |
      | components_with_type | Component     | Admin,RequestRouter     |
      | register_component   | Component     | Admin,RequestRouter     |
      | unregister_component | Component     | Admin,RequestRouter     |
      | available_routes     | RequestRouter | Admin,Component         |
      | component_command    | Admin         | Component,RequestRouter |
      | component_pid        | Admin         | Component,RequestRouter |
      | daemonize            | Admin         | Component,RequestRouter |


