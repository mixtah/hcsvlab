Feature: Home page
  In order to meet our obligations
  As the system owner
  I want appropriate attribution text on the home page

  Background:
    Given I have the usual roles and permissions
    And I have a user "data_owner@alveo.edu.au" with role "data owner"
    And I have a user "researcher@alveo.edu.au" with role "researcher"
    And I have a user "chrisk@alveo.edu.au"
    And "chrisk@alveo.edu.au" has role "admin"

  Scenario: Text is shown when not logged in
    Given I am on the home page
    Then I should see "Western Sydney University and Alveo acknowledges funding from Nectar."
    And I should see "Nectar is supported by the Australian Government through the National Collaborative Research Infrastructure Strategy (NCRIS)."

  Scenario: Text is shown when logged in
    Given I am logged in as "chrisk@alveo.edu.au"
    Then I should see "Western Sydney University and Alveo acknowledges funding from Nectar."
    And I should see "Nectar is supported by the Australian Government through the National Collaborative Research Infrastructure Strategy (NCRIS)."

  Scenario: Licences Agreement link should appear for users which do not have access to any collection
    Given I ingest "cooee:1-001"
    Given I ingest "auslit:adaessa"
    Given Collections ownership is
      | collection | owner_email                 |
      | austlit    | data_owner@alveo.edu.au |
      | cooee      | data_owner@alveo.edu.au |
    Given I am logged in as "researcher@alveo.edu.au"
    Given I am on the home page
    Then I should see "Welcome! To gain access to Collections, visit the Licence Agreements page."

  Scenario: Licences Agreement link should appear for users which have access to some collection
    Given I ingest "cooee:1-001"
    Given I ingest "auslit:adaessa"
    Given "researcher@alveo.edu.au" has "read" access to collection "cooee"
    Given I am logged in as "researcher@alveo.edu.au"
    Given I am on the home page
    Then I should see "Welcome! To gain access to more Collections, visit the Licence Agreements page."

  Scenario: Licences Agreement link should not appear for users which have access to every collection
    Given I ingest "cooee:1-001"
    Given I ingest "auslit:adaessa"
    Given "researcher@alveo.edu.au" has "read" access to collection "austlit"
    Given "researcher@alveo.edu.au" has "read" access to collection "cooee"
    Given I am logged in as "researcher@alveo.edu.au"
    Given I am on the home page
    Then I should not see "Welcome! To gain access to Collections, visit the Licence Agreements page."
    And I should not see "Welcome! To gain access to more Collections, visit the Licence Agreements page."
