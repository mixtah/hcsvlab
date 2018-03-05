Feature: Managing Collection Lists and Licences
  As a Data Owner, I want to create a Collection List,
  so I can associate a licence with multiple collections at once.

  Background:
    Given I have the usual roles and permissions
    Given I have users
      | email                        | first_name | last_name |
      | data_owner@alveo.edu.au  | dataOwner  | One       |
      | data_owner2@alveo.edu.au | dataOwner  | Two       |
      | research@alveo.edu.au    | research   | student   |
    Given "data_owner@alveo.edu.au" has role "data owner"
    And "data_owner2@alveo.edu.au" has role "data owner"
    And "research@alveo.edu.au" has role "researcher"
    And I ingest "cooee:1-001"
    And I ingest "auslit:adaessa"
    And I ingest "ice:S2B-035"
    And Collections ownership is
      | collection | owner_email                  |
      | ice        | data_owner2@alveo.edu.au |
    And I ingest licences
    And I am logged in as "data_owner@alveo.edu.au"
    And I am on the licences page

  @javascript
  Scenario: Verifying initial page data
    And I should see "There are no Collection Lists created."
    And The Collection table should have
      | collection | licence     | licence_terms |
      | austlit    | Add Licence |               |
      | cooee      | Add Licence |               |
    And I click Add Licence for the 1st collection
    Then I should see "Creative Commons v3.0 BY-NC"
    And I should see "AusNC Terms of Use"


  @javascript
  Scenario: Creating an empty Collection List
    And I follow "Add selected to Collection list"
    And I follow "Create New Collection List"
    And I wait for 2 seconds
    And I should see "Create New Collection list"
    And I fill in "Name" with "Collection List 1"
    And I press "Create Collection List"
    And I should see "You can not create an empty Collection List, please select at least one Collection."

  @javascript
  Scenario: Creating a Collection List with one Collection
    And I choose the 1st Collection in the list
    And I follow "Add selected to Collection list"
    And I follow "Create New Collection List"
    And I wait for 2 seconds
    And I should see "Create New Collection list"
    And I fill in "Name" with "Collection List 1"
    And I press "Create Collection List"
    And The Collection Lists table should have
      | collection_list   | owner                       | licence     | licence_terms | collections |
      | Collection List 1 | data_owner@alveo.edu.au | Add Licence |               | austlit     |
    And The Collection table should have
      | collection | collection_list   | licence     | licence_terms |
      | cooee      |                   | Add Licence |               |

  @javascript
  Scenario: Creating a Collection List with all Collection
    When I check "allnonecheckbox"
    And I follow "Add selected to Collection list"
    And I follow "Create New Collection List"
    And I wait for 2 seconds
    And I should see "Create New Collection list"
    And I fill in "Name" with "Collection List 1"
    And I press "Create Collection List"
    And The Collection Lists table should have
      | collection_list   | owner                       | licence     | licence_terms | collections   |
      | Collection List 1 | data_owner@alveo.edu.au | Add Licence |               | austlit,cooee |
    And The Collection table should have
      | collection | collection_list   | licence | licence_terms |
  @javascript
  Scenario: Creating two collection lists with one collection each
    And I choose the 1st Collection in the list
    And I follow "Add selected to Collection list"
    And I follow "Create New Collection List"
    And I wait for 2 seconds
    And I should see "Create New Collection list"
    And I fill in "Name" with "Collection List 1"
    And I press "Create Collection List"
    And The Collection Lists table should have
      | collection_list   | owner                       | licence     | licence_terms | collections |
      | Collection List 1 | data_owner@alveo.edu.au | Add Licence |               | austlit     |
    And The Collection table should have
      | collection | collection_list   | licence     | licence_terms |
      | cooee      |                   | Add Licence |               |
    Then I check "allnonecheckbox"
    And I follow "Add selected to Collection list"
    And I follow "Create New Collection List"
    And I wait for 2 seconds
    And I should see "Create New Collection list"
    And I fill in "Name" with "Collection List 2"
    And I press "Create Collection List"
    And The Collection Lists table should have
      | collection_list   | owner                       | licence     | licence_terms | collections |
      | Collection List 1 | data_owner@alveo.edu.au | Add Licence |               | austlit     |
      | Collection List 2 | data_owner@alveo.edu.au | Add Licence |               | cooee       |
    And The Collection table should have
      | collection | collection_list   | licence | licence_terms |

  @javascript
  Scenario: Creating two collection lists with the same name
    And I choose the 1st Collection in the list
    And I follow "Add selected to Collection list"
    And I follow "Create New Collection List"
    And I wait for 2 seconds
    And I should see "Create New Collection list"
    And I fill in "Name" with "Collection List 1"
    And I press "Create Collection List"
    And The Collection Lists table should have
      | collection_list   | owner                       | licence     | licence_terms |
      | Collection List 1 | data_owner@alveo.edu.au | Add Licence |               |
    Then I check "allnonecheckbox"
    And I follow "Add selected to Collection list"
    And I follow "Create New Collection List"
    And I wait for 2 seconds
    And I should see "Create New Collection list"
    And I fill in "Name" with "Collection List 1"
    And I press "Create Collection List"
    Then I should see "Create New Collection list"
    And I should see "Collection list name already exists"
    Then I click "Close"
    And The Collection Lists table should have
      | collection_list   | owner                       | licence     | licence_terms | collections |
      | Collection List 1 | data_owner@alveo.edu.au | Add Licence |               | austlit     |
    And The Collection table should have
      | collection | collection_list   | licence     | licence_terms |
      | cooee      |                   | Add Licence |               |

  @javascript
  Scenario: Assign licence to a Collection
    And The Collection table should have
      | collection | collection_list | licence     | licence_terms |
      | austlit    |                 | Add Licence |               |
      | cooee      |                 | Add Licence |               |
    And I click Add Licence for the 1st collection
    And I follow "Creative Commons v3.0 BY-NC"
    Then The Collection table should have
      | collection | collection_list | licence                     | licence_terms      |
      | austlit    |                 | Creative Commons v3.0 BY-NC | View Licence Terms |
      | cooee      |                 | Add Licence                 |                    |
    And I should see "Successfully added licence to austlit"

  @javascript
  Scenario: Assign licence to a Collection List
    And I choose the 1st Collection in the list
    And I follow "Add selected to Collection list"
    And I follow "Create New Collection List"
    And I wait for 2 seconds
    And I should see "Create New Collection list"
    And I fill in "Name" with "Collection List 1"
    And I press "Create Collection List"
    And The Collection Lists table should have
      | collection_list   | owner                       | licence     | licence_terms | collections |
      | Collection List 1 | data_owner@alveo.edu.au | Add Licence |               | austlit     |
    And The Collection table should have
      | collection | collection_list   | licence     | licence_terms |
      | cooee      |                   | Add Licence |               |
    Then I click Add Licence for the 1st collection list
    And I follow "Creative Commons v3.0 BY-NC"
    And The Collection Lists table should have
      | collection_list   | owner                       | licence                     | licence_terms      | collections |
      | Collection List 1 | data_owner@alveo.edu.au | Creative Commons v3.0 BY-NC | View Licence Terms | austlit     |
    And The Collection table should have
      | collection | collection_list   | licence                     | licence_terms      |
      | cooee      |                   | Add Licence                 |                    |

  @javascript
  Scenario: Remove a collection list
    And I choose the 1st Collection in the list
    And I follow "Add selected to Collection list"
    And I follow "Create New Collection List"
    And I wait for 2 seconds
    And I should see "Create New Collection list"
    And I fill in "Name" with "Collection List 1"
    And I press "Create Collection List"
    And The Collection Lists table should have
      | collection_list   | owner                       | licence     | licence_terms | collections |
      | Collection List 1 | data_owner@alveo.edu.au | Add Licence |               | austlit     |
    And The Collection table should have
      | collection | collection_list   | licence     | licence_terms |
      | cooee      |                   | Add Licence |               |
    Then I click on the remove icon for the 1st collection list
    And The popup text should contain "Are you sure you want to remove the Collections List"
    Then I confirm the popup
    And The Collection table should have
      | collection | collection_list | licence     | licence_terms |
      | austlit    |                 | Add Licence |               |
      | cooee      |                 | Add Licence |               |

  @javascript
  Scenario: View licence terms of a Collection
    And The Collection table should have
      | collection | collection_list | licence     | licence_terms |
      | austlit    |                 | Add Licence |               |
      | cooee      |                 | Add Licence |               |
    And I click Add Licence for the 1st collection
    And I follow "Creative Commons v3.0 BY-NC"
    Then The Collection table should have
      | collection | collection_list | licence                     | licence_terms      |
      | austlit    |                 | Creative Commons v3.0 BY-NC | View Licence Terms |
      | cooee      |                 | Add Licence                 |                    |
    When I click View Licence Terms for the 1st collection
    Then I should see "THE WORK (AS DEFINED BELOW) IS PROVIDED UNDER THE TERMS OF THIS CREATIVE COMMONS PUBLIC LICENCE."

  @javascript
  Scenario: Create new licence and assign it to a collection
    And The Collection table should have
      | collection | collection_list | licence     | licence_terms |
      | austlit    |                 | Add Licence |               |
      | cooee      |                 | Add Licence |               |
    And I click Add Licence for the 1st collection
    And I follow "Create New"
    And I fill in "Licence name" with "Licence 1"
    And I fill in tiny_mce editor with "This is the text of Licence 1"
    And I press "Create"
    Then I should see "Licence created successfully"
    Then The Collection table should have
      | collection | collection_list | licence     | licence_terms      |
      | austlit    |                 | Licence 1   | View Licence Terms |
      | cooee      |                 | Add Licence |                    |
    When I click View Licence Terms for the 1st collection
    Then I should see "This is the text of Licence 1"

  @javascript
  Scenario: Create duplicated licence
    And The Collection table should have
      | collection | collection_list | licence     | licence_terms |
      | austlit    |                 | Add Licence |               |
      | cooee      |                 | Add Licence |               |
    And I click Add Licence for the 1st collection
    And I follow "Create New"
    And I fill in "Licence name" with "Licence 1"
    And I fill in tiny_mce editor with "This is the text of Licence 1"
    And I press "Create"
    Then I should see "Licence created successfully"
    Then The Collection table should have
      | collection | collection_list | licence     | licence_terms      |
      | austlit    |                 | Licence 1   | View Licence Terms |
      | cooee      |                 | Add Licence |                    |
    And I click Add Licence for the 1st collection
    And I follow "Create New"
    And I fill in "Licence name" with "Licence 1"
    And I fill in tiny_mce editor with "This is the text of Licence 1"
    And I press "Create"
    Then I should see "Licence name 'Licence 1' already exists"
    And I fill in "Licence name" with "AusNC Terms of Use"
    And I fill in tiny_mce editor with "This is the text of Licence 1"
    And I press "Create"
    Then I should see "Licence name 'AusNC Terms of Use' already exists"

    And I am logged out
    And I am logged in as "data_owner2@alveo.edu.au"
    And I am on the licences page
    And The Collection table should have
      | collection | collection_list | licence     | licence_terms |
      | ice        |                 | Add Licence |               |
    And I click Add Licence for the 1st collection
    And I follow "Create New"
    And I fill in "Licence name" with "AusNC Terms of Use"
    And I fill in tiny_mce editor with "This is the text of Licence 1"
    And I press "Create"
    Then I should see "Licence name 'AusNC Terms of Use' already exists"
    And I fill in "Licence name" with "Licence 1"
    And I fill in tiny_mce editor with "This is the text of Licence 1"
    And I press "Create"
    Then I should see "Licence created successfully"
    Then The Collection table should have
      | collection | collection_list | licence   | licence_terms      |
      | ice        |                 | Licence 1 | View Licence Terms |

  @javascript
  Scenario: Create licence with empty name
    And The Collection table should have
      | collection | collection_list | licence     | licence_terms |
      | austlit    |                 | Add Licence |               |
      | cooee      |                 | Add Licence |               |
    And I click Add Licence for the 1st collection
    And I follow "Create New"
    And I fill in "Licence name" with ""
    And I fill in tiny_mce editor with "This is the text of Licence 1"
    And I press "Create"
    Then I should see "Licence Name can not be blank"

  @javascript
  Scenario: Change a collection list's privacy status
    When I check "allnonecheckbox"
    And I follow "Add selected to Collection list"
    And I follow "Create New Collection List"
    And I wait for 2 seconds
    And I fill in "Name" with "Collection List 1"
    And I press "Create Collection List"
    Then I click on the privacy remove icon for the 1st collection list
    Then I should see "Collection List 1 has been successfully marked as requiring approval"

  @javascript
  Scenario: Change a collection's privacy status
    Then I click on the privacy remove icon for the 1st collection
    Then I should see "austlit has been successfully marked as requiring approval"
    And I have added a licence to private Collection "austlit"
    And I follow "data_owner@alveo.edu.au"
    And I follow "Logout"
    And I am logged in as "research@alveo.edu.au"
    And I am on the licence agreements page
    Then the Review and Acceptance of Licence Terms table should have
      | title   | collection | owner                       | state      |
      | austlit | 1          | data_owner@alveo.edu.au | Unapproved |
    And I should see "Review Licence Terms"
    And I should see "Request Access"
    And I should not see "Preview & Accept Licence Terms"

  @javascript
  Scenario: Change a collection's privacy status with pending licence requests
    When I have users
      | email                       | first_name | last_name |
      | researcher@alveo.edu.au | researcher | One       |
    And "researcher@alveo.edu.au" has role "researcher"
    Then I click on the privacy remove icon for the 1st collection
    And I should see "austlit has been successfully marked as requiring approval"
    And there is a licence request for collection "austlit" by "researcher@alveo.edu.au"
    Then I click on the privacy remove icon for the 1st collection
    And I should see "austlit has been successfully marked as not requiring approval"
    And I am on the licence requests page
    Then I should see "No requests to display"

  @javascript
  Scenario: Change a collection list's privacy status with pending licence requests
    When I have users
      | email                       | first_name | last_name |
      | researcher@alveo.edu.au | researcher | One       |
    And "researcher@alveo.edu.au" has role "researcher"
    When I check "allnonecheckbox"
    And I follow "Add selected to Collection list"
    And I follow "Create New Collection List"
    And I wait for 2 seconds
    And I fill in "Name" with "Collection List 1"
    And I check "collection_list_private"
    And I press "Create Collection List"
    And there is a licence request for collection list "Collection List 1" by "researcher@alveo.edu.au"
    And I click on the privacy remove icon for the 1st collection list
    And I should see "Collection List 1 has been successfully marked as not requiring approval"
    And I am on the licence requests page
    Then I should see "No requests to display"
    And I have added a licence to Collection List "Collection List 1"
    And I follow "data_owner@alveo.edu.au"
    And I follow "Logout"
    And I am logged in as "research@alveo.edu.au"
    And I am on the licence agreements page
    Then the Review and Acceptance of Licence Terms table should have
      | title             | collection | owner                       | state        |
      | Collection List 1 | 2          | data_owner@alveo.edu.au | Not Accepted |
    And I should see "Preview & Accept Licence Terms"
    And I should not see "Review Licence Terms"
    And I should not see "Request Access"

  @javascript
  Scenario: Delete a collection list with pending licence requests
    When I have users
      | email                       | first_name | last_name |
      | researcher@alveo.edu.au | researcher | One       |
    And "researcher@alveo.edu.au" has role "researcher"
    When I check "allnonecheckbox"
    And I follow "Add selected to Collection list"
    And I follow "Create New Collection List"
    And I wait for 2 seconds
    And I fill in "Name" with "Collection List 1"
    And I check "collection_list_private"
    And I press "Create Collection List"
    And there is a licence request for collection list "Collection List 1" by "researcher@alveo.edu.au"
    And I click on the remove icon for the 1st collection list
    And I should see "Collection list Collection List 1 deleted successfully"
    And I am on the licence requests page
    Then I should see "No requests to display"

  @javascript
  Scenario: Revoke access to a collection
    When I have users
      | email                        | first_name | last_name |
      | researcher1@alveo.edu.au | researcher | One       |
      | researcher2@alveo.edu.au | researcher | Two       |
    And "researcher1@alveo.edu.au" has role "researcher"
    And "researcher2@alveo.edu.au" has role "researcher"
    And I have user "researcher1@alveo.edu.au" with the following groups
      | collectionName | accessType |
      | austlit        | read       |
    And I click Add Licence for the 1st collection
    And I follow "Creative Commons v3.0 BY-NC"
    And I click on the privacy remove icon for the 1st collection
    And I should see "austlit has been successfully marked as requiring approval"
    And there is a licence request for collection "austlit" by "researcher2@alveo.edu.au"
    And I follow "Revoke Access"
    Then I should see "Are you sure you want to revoke access to austlit for all users?"
    And I follow element with id "revoke_access0"
    Then I should see "All access to austlit has been successfully revoked"
    And I am on the licence requests page
    Then I should see "No requests to display"

  @javascript
  Scenario: Revoke access to a collection list
    When I have users
      | email                        | first_name | last_name |
      | researcher1@alveo.edu.au | researcher | One       |
      | researcher2@alveo.edu.au | researcher | Two       |
    And "researcher1@alveo.edu.au" has role "researcher"
    And "researcher2@alveo.edu.au" has role "researcher"
    And I have user "researcher1@alveo.edu.au" with the following groups
      | collectionName | accessType |
      | austlit        | read       |
    And I choose the 1st Collection in the list
    And I follow "Add selected to Collection list"
    And I follow "Create New Collection List"
    And I wait for 2 seconds
    And I should see "Create New Collection list"
    And I fill in "Name" with "Collection List 1"
    And I check "collection_list_private"
    And I press "Create Collection List"
    And I click Add Licence for the 1st collection list
    And I follow "Creative Commons v3.0 BY-NC"
    And there is a licence request for collection list "Collection List 1" by "researcher2@alveo.edu.au"
    And I follow "Revoke Access"
    Then I should see "Are you sure you want to revoke access to Collection List 1 for all users?"
    And I follow element with id "revoke_list_access0"
    Then I should see "All access to Collection List 1 has been successfully revoked"
    And I am on the licence requests page
    Then I should see "No requests to display"

  @javascript
  Scenario: Can see all collections
    When I have 15 licences belonging to "data_owner@alveo.edu.au"
    And I am on the licences page
    Then I should see "Licence 01"
    And I should see "Licence 02"
    And I should see "Licence 03"
    And I should see "Licence 04"
    And I should see "Licence 05"
    And I should see "Licence 06"
    And I should see "Licence 07"
    And I should see "Licence 08"
    And I should see "Licence 09"
    And I should see "Licence 10"
    And I should see "Licence 11"
    And I should see "Licence 12"
    And I should see "Licence 13"
    And I should see "Licence 14"
    And I should see "Licence 15"


