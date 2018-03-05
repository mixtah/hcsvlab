Feature: Managing Item Lists
  As a Researcher,
  I want to download my item lists using aspera
  So that I access download collections quicker

  Background:
    Given I have the usual roles and permissions
    And I have users
      | email                        | first_name | last_name |
      | researcher@alveo.edu.au  | Researcher | One       |
      | data_owner@alveo.edu.au  | Data       | Owner     |
    And "researcher@alveo.edu.au" has role "researcher"
    And "data_owner@alveo.edu.au" has role "data owner"
    And "researcher@alveo.edu.au" has an api token
    And I ingest "cooee:1-001"
    And I ingest "cooee:1-002"
    And I have user "researcher@alveo.edu.au" with the following groups
      | collectionName | accessType |
      | cooee          | read       |
    And I am logged in as "researcher@alveo.edu.au"
    And "researcher@alveo.edu.au" has item lists
      | name |
      | Test |

  Scenario: I have option to download item list using aspera
    Given "researcher@alveo.edu.au" has item lists
      | name  |
      | Test1 |
    And the item list "Test1" has items cooee:1-001
    And the item list "Test1" has items cooee:1-002
    And I am on the item list page for "Test1"
    And I should see "Download using Aspera"

  #Scenario: I am prompted to download aspera connect plugin is not installed
  # Note: cannot test this scenario due to external dependency on having aspera connect plugin installed on system

  #Scenario: I can download files using aspera connect plugin
  # Note: cannot test this scenario due to external dependency on having aspera connect plugin installed on system

  Scenario: Get an aspera transfer specification for an empty item list
    Given I make a JSON post request for the transfer spec page for item list "Test" with the API token for "researcher@alveo.edu.au" without JSON params
    Then I should get a 200 response code
    And the JSON response should be:
    """
    {
      "message":"No items were found to download"
    }
    """
