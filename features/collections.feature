Feature: Collections
  As a Researcher,
  I want to view collections and their details

  Background:
    Given I have the usual roles and permissions
    And I have a user "data_owner@alveo.edu.au" with role "data owner"
    And I have a user "researcher@alveo.edu.au" with role "researcher"
    And I ingest "cooee:1-001"
    And I ingest "auslit:adaessa"
    And I am logged in as "researcher@alveo.edu.au"

  Scenario: View list of collections
    Given I am on the collections page
    Then I should see "Collections"
    And I should see "cooee"
    And I should see "austlit"
    And I should see "Select a collection to view"

  Scenario: Access collection details from the collections page
    Given I am on the collections page
    And I follow "austlit"
    Then I should see "austlit"
    And I should see "Collection Details"
    And I should see "Title: AustLit "
    And I should see "Access Rights: See AusNC Terms of Use "
    And I should see "Created: 2000 to present "
    And I should see "Is Part Of: Australian National Corpus - http://www.ausnc.org.au "
    And I should see "Language: eng"
    And I should see "Owner: University of Queensland. "
    And I should see "SPARQL Endpoint: http://www.example.com/sparql/austlit"
    And I should not see "Back to Licence Agreements"

  Scenario: Access collection details from item details page
    Given "researcher@alveo.edu.au" has "read" access to collection "cooee"
    Given I am on the catalog page for "cooee:1-001"
    And I follow "cooee"
    Then I should be on the collection page for "cooee"
    And I should see "cooee"
    And I should see "Collection Details"
    And I should see "Title: Corpus of Oz Early English "
    And I should see "Access Rights: See AusNC Terms of Use "
    And I should see "Created: 2004 "
    And I should see "Extent: 2,000,000 words, 1353 text samples"
    And I should see "Language: eng"
    And I should see "Owner: None. Individual owner is Clemens Fritz. "
    And I should see "SPARQL Endpoint: http://www.example.com/sparql/cooee"
    And I should not see "Back to Licence Agreements"
