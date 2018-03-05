Feature: Administer users
  In order to allow users to access the system
  As an administrator
  I want to administer users

  Background:
    Given I have users
      | email                       | first_name | last_name |
      | raul@alveo.edu.au       | Raul       | Carrizo   |
      | georgina@alveo.edu.au   | Georgina   | Edwards   |
      | data_owner@alveo.edu.au | Data       | Owner     |
    And I have the usual roles and permissions
    And I am logged in as "georgina@alveo.edu.au"
    And "georgina@alveo.edu.au" has role "admin"
    And "data_owner@alveo.edu.au" has role "data owner"

  Scenario: View a list of users
    Given "raul@alveo.edu.au" is deactivated
    When I am on the list users page
    Then I should see "users" table with
      | First name | Last name | Email                       | Role       | Status      |
      | Data       | Owner     | data_owner@alveo.edu.au | data owner | Active      |
      | Georgina   | Edwards   | georgina@alveo.edu.au   | admin      | Active      |
      | Raul       | Carrizo   | raul@alveo.edu.au       |            | Deactivated |

  Scenario: View user details
    Given "raul@alveo.edu.au" has role "researcher"
    And I am on the list users page
    When I follow "View Details" for "raul@alveo.edu.au"
    Then I should see field "Email" with value "raul@alveo.edu.au"
    And I should see field "First Name" with value "Raul"
    And I should see field "Last Name" with value "Carrizo"
    And I should see field "Role" with value "researcher"
    And I should see field "Status" with value "Active"

  Scenario: Go back from user details
    Given I am on the list users page
    When I follow "View Details" for "georgina@alveo.edu.au"
    And I follow "Back"
    Then I should be on the list users page

  Scenario: Edit role
    Given "raul@alveo.edu.au" has role "researcher"
    And I am on the list users page
    When I follow "View Details" for "raul@alveo.edu.au"
    And I follow "Edit role"
    And I select "admin" from "Role"
    And I press "Save"
    Then I should be on the user details page for raul@alveo.edu.au
    And I should see "The role for raul@alveo.edu.au was successfully updated."
    And I should see field "Role" with value "admin"

  Scenario: Edit role from list page
    Given "raul@alveo.edu.au" has role "researcher"
    And I am on the list users page
    When I follow "Edit role" for "raul@alveo.edu.au"
    And I select "data owner" from "Role"
    And I press "Save"
    Then I should be on the user details page for raul@alveo.edu.au
    And I should see "The role for raul@alveo.edu.au was successfully updated."
    And I should see field "Role" with value "data owner"

  Scenario: Cancel out of editing roles
    Given "raul@alveo.edu.au" has role "researcher"
    And I am on the list users page
    When I follow "View Details" for "raul@alveo.edu.au"
    And I follow "Edit role"
    And I select "admin" from "Role"
    And I follow "Back"
    Then I should be on the user details page for raul@alveo.edu.au
    And I should see field "Role" with value "researcher"

  Scenario: Role should be mandatory when editing Role
    And I am on the list users page
    When I follow "View Details" for "raul@alveo.edu.au"
    And I follow "Edit role"
    And I select "" from "Role"
    And I press "Save"
    Then I should see "Please select a role for the user."

  Scenario: Deactivate active user
    Given I am on the list users page
    When I follow "View Details" for "raul@alveo.edu.au"
    And I follow "Deactivate"
    Then I should see "The user has been deactivated"
    And I should see "Activate"

  Scenario: Activate deactivated user
    Given "raul@alveo.edu.au" is deactivated
    And I am on the list users page
    When I follow "View Details" for "raul@alveo.edu.au"
    And I follow "Activate"
    Then I should see "The user has been activated"
    And I should see "Deactivate"

  Scenario: Can't deactivate the last administrator account
    Given I am on the list users page
    When I follow "View Details" for "georgina@alveo.edu.au"
    And I follow "Deactivate"
    Then I should see "You cannot deactivate this account as it is the only account with admin privileges."
    And I should see field "Status" with value "Active"

  Scenario: Editing own role has alert
    Given I am on the list users page
    When I follow "View Details" for "georgina@alveo.edu.au"
    And I follow "Edit role"
    Then I should see "You are changing the role of the user you are logged in as."

  Scenario: Should not be able to edit role of rejected user by direct URL entry
    Given I have a rejected as spam user "spam@alveo.edu.au"
    And I go to the edit role page for spam@alveo.edu.au
    Then I should be on the list users page
    And I should see "Role can not be set. This user has previously been rejected as a spammer."

  Scenario: Count of users with role 'researcher' is shown on user list page
    Given I have 4 active users with role "researcher"
    And I have 2 deactivated users with role "researcher"
    And I have 3 active users with role "admin"
    When I am on the list users page
    Then I should see "There are 4 registered users with role 'researcher'."

  Scenario: I must be logged in to administer users
    Given I follow "georgina@alveo.edu.au"
    And I follow "Logout"
    And I am on the admin page
    Then I should see "Please enter your email and password to log in"
