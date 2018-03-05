Feature: Managing Item Lists
  As a Researcher,
  I want to download my item lists as a zip
  So that I can access item documents

  Background:
    Given I have the usual roles and permissions
    And I have users
      | email                        | first_name | last_name |
      | researcher@alveo.edu.au  | Researcher | One       |
    And "researcher@alveo.edu.au" has role "researcher"
    And "researcher@alveo.edu.au" has an api token
    And I have user "researcher@alveo.edu.au" with the following groups
      | collectionName | accessType |
      | cooee          | read       |
    And I am logged in as "researcher@alveo.edu.au"
    And "researcher@alveo.edu.au" has item lists
      | name |
      | Test1 |

  Scenario: I have option to download item list as a zip
    Given "researcher@alveo.edu.au" has item lists
      | name  |
      | Test1 |
    And the item list "Test1" has 1 text documents
    When I am on the item list page for "Test1"
    Then I should see "Download as ZIP"

  Scenario: I have multiple options to download item list as a zip
    Given "researcher@alveo.edu.au" has item lists
      | name  |
      | Test1 |
    And the item list "Test1" has 1 text documents
    When I am on the item list page for "Test1"
    And I click "Download as ZIP"
    Then I should see "Download Options for Item List: Test1"
    And I should see "Download all files"
    And I should see "Download All"
    And I should see "Download only files of a particular type"
    And I should see "txt"
    And I should see "Download Selected"
    And I should see "Download only files that match a particular regular expression"
    And I should see "Download Matches"

  Scenario: Downloading more than 200 documents results in an error
    Given "researcher@alveo.edu.au" has item lists
      | name  |
      | Test1 |
    And the item list "Test1" has 201 text documents
    When I am on the item list page for "Test1"
    And I click "Download as ZIP"
    And I press "Download All"
    Then I should see "Zip download is limited to 200 files"

  Scenario: Remote documents can be downloaded not result in an error
    Given "researcher@alveo.edu.au" has item lists
      | name  |
      | Test1 |
    And the item list "Test1" has 101 items with two remote documents each
    When I am on the item list page for "Test1"
    And I click "Download as ZIP"
    And I filter by "*.txt"
    And I press "Download Selected"
    Then I should not see "Zip download is limited to 200 files"

  Scenario: Documents without extensions can be filtered
    Given "researcher@alveo.edu.au" has item lists
      | name  |
      | Test1 |
    And the item list "Test1" has 101 items with two remote documents each
    When I am on the item list page for "Test1"
    And I click "Download as ZIP"
    And I filter by "no extension"
    And I press "Download Selected"
    Then I should not see "Zip download is limited to 200 files"