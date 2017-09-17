Feature: Approve access requests
  In order to allow users to access the system
  As an administrator
  I want to approve access requests

  Background:
    Given I have roles
      | name       |
      | admin      |
      | Researcher |
    And I have a user "georgina@alveo.edu.au" with role "admin"
    And I have access requests
      | email                  | first_name | last_name        |
      | ryan@alveo.edu.au  | Ryan       | Braganza         |
      | diego@alveo.edu.au | Diego      | Alonso de Marcos |
    And I am logged in as "georgina@alveo.edu.au"

  Scenario: View a list of access requests
    Given I am on the access requests page
    Then I should see "access_requests" table with
      | First name | Last name        | Email                  |
      | Diego      | Alonso de Marcos | diego@alveo.edu.au |
      | Ryan       | Braganza         | ryan@alveo.edu.au  |

  Scenario: Approve an access request from the list page
    Given I am on the access requests page
    When I follow "Approve" for "diego@alveo.edu.au"
    And I select "admin" from "Role"
    And I press "Approve"
    Then I should see "The access request for diego@alveo.edu.au was approved."
    And I should see "access_requests" table with
      | First name | Last name | Email                 |
      | Ryan       | Braganza  | ryan@alveo.edu.au |
    And "diego@alveo.edu.au" should receive an email with subject "Alveo - Your access request has been approved"
    When they open the email
    Then they should see "You made a request for access to the Alveo System. Your request has been approved. Please visit" in the email body
    And they should see "Hello Diego Alonso de Marcos," in the email body
    When they click the first link in the email
    Then I should be on the home page

  Scenario: Cancel out of approving an access request from the list page
    Given I am on the access requests page
    When I follow "Approve" for "diego@alveo.edu.au"
    And I select "admin" from "Role"
    And I follow "Back"
    Then I should be on the access requests page
    And I should see "access_requests" table with
      | First name | Last name        | Email                  |
      | Diego      | Alonso de Marcos | diego@alveo.edu.au |
      | Ryan       | Braganza         | ryan@alveo.edu.au  |

  Scenario: View details of an access request
    Given I am on the access requests page
    When I follow "View Details" for "diego@alveo.edu.au"
    Then I should see "diego@alveo.edu.au"
    Then I should see field "Email" with value "diego@alveo.edu.au"
    Then I should see field "First Name" with value "Diego"
    Then I should see field "Last Name" with value "Alonso de Marcos"
    Then I should see field "Role" with value ""
    Then I should see field "Status" with value "Pending Approval"

  Scenario: Approve an access request from the view details page
    Given I am on the access requests page
    When I follow "View Details" for "diego@alveo.edu.au"
    And I follow "Approve"
    And I select "admin" from "Role"
    And I press "Approve"
    Then I should see "The access request for diego@alveo.edu.au was approved."
    And I should see "access_requests" table with
      | First name | Last name | Email                 |
      | Ryan       | Braganza  | ryan@alveo.edu.au |

  Scenario: Cancel out of approving an access request from the view details page
    Given I am on the access requests page
    When I follow "View Details" for "diego@alveo.edu.au"
    And I follow "Approve"
    And I select "admin" from "Role"
    And I follow "Back"
    Then I should be on the access requests page
    And I should see "access_requests" table with
      | First name | Last name        | Email                  |
      | Diego      | Alonso de Marcos | diego@alveo.edu.au |
      | Ryan       | Braganza         | ryan@alveo.edu.au  |

  Scenario: Go back to the access requests page from the view details page without doing anything
    Given I am on the access requests page
    And I follow "View Details" for "diego@alveo.edu.au"
    When I follow "Back"
    Then I should be on the access requests page
    And I should see "access_requests" table with
      | First name | Last name        | Email                  |
      | Diego      | Alonso de Marcos | diego@alveo.edu.au |
      | Ryan       | Braganza         | ryan@alveo.edu.au  |

  Scenario: Role should be mandatory when approving an access request
    Given I am on the access requests page
    When I follow "Approve" for "diego@alveo.edu.au"
    And I press "Approve"
    Then I should see "Please select a role for the user."

  Scenario: Approved user should be able to log in
    Given I am on the access requests page
    When I follow "Approve" for "diego@alveo.edu.au"
    And I select "admin" from "Role"
    And I press "Approve"
    And I am on the home page
    And I follow "Logout"
    Then I should be able to log in with "diego@alveo.edu.au" and "Pas$w0rd"

  Scenario: Approved user roles should be correctly saved
    Given I am on the access requests page
    And I follow "Approve" for "diego@alveo.edu.au"
    And I select "admin" from "Role"
    And I press "Approve"
    And I am on the list users page
    When I follow "View Details" for "diego@alveo.edu.au"
    And I should see field "Role" with value "admin"
