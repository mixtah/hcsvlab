Feature: Deleting Documents
  As a Data Owner,
  I want to delete documents from my items

  Background:
    Given I have the usual roles and permissions
    And I have a user "data_owner@alveo.edu.au" with role "data owner"
    And "data_owner@alveo.edu.au" has an api token
    And I have a user "researcher@alveo.edu.au" with role "researcher"
    And I ingest "cooee:1-001"
    And I have user "researcher@alveo.edu.au" with the following groups
      | collectionName | accessType |
      | cooee          | read       |

  Scenario: Verify delete document button is visible for item owner
    Given I am logged in as "data_owner@alveo.edu.au"
    When I am on the catalog page for "cooee:1-001"
    Then I should see a page with the title: "Alveo - cooee:1-001"
    And I should see "cooee:1-001"
    And I should see "Display Document"
    And I should see "Documents: 1-001#Text, 1-001#Original, 1-001#Raw"
    And I should see "Filename        Type      Size    Delete"
    And I should see "1-001-plain.txt Text      5.0 kB"
    And I should see link "Closebox" to "/catalog/cooee/1-001/document/1-001-plain.txt/delete"
    And I should see "1-001.txt       Original  5.1 kB"
    And I should see link "Closebox" to "/catalog/cooee/1-001/document/1-001.txt/delete"
    And I should see "1-001-raw.txt   Raw       5.1 kB"
    And I should see link "Closebox" to "/catalog/cooee/1-001/document/1-001-raw.txt/delete"

  Scenario: Verify delete document button isn't visible users apart from the item owner
    Given I am logged in as "researcher@alveo.edu.au"
    When I am on the catalog page for "cooee:1-001"
    Then I should see a page with the title: "Alveo - cooee:1-001"
    And I should see "cooee:1-001"
    And I should see "Display Document"
    And I should see "Documents: 1-001#Text, 1-001#Original, 1-001#Raw"
    And I should see "Filename        Type      Size"
    And I should not see "Filename    Type      Size    Delete"
    And I should see "1-001-plain.txt Text      5.0 kB"
    And I should not see link "Closebox" to "/catalog/cooee/1-001/document/1-001-plain.txt/delete"
    And I should see "1-001.txt       Original  5.1 kB"
    And I should not see link "Closebox" to "/catalog/cooee/1-001/document/1-001.txt/delete"
    And I should see "1-001-raw.txt   Raw       5.1 kB"
    And I should not see link "Closebox" to "/catalog/cooee/1-001/document/1-001-raw.txt/delete"

  @create_collection
  Scenario: Verify direct url to delete document won't work for users apart from the item owner
    Given I ingest a new collection "test" through the api with the API token for "data_owner@alveo.edu.au"
    And I make a JSON post request for the collection page for id "test" with the API token for "data_owner@alveo.edu.au" with JSON params
      | items |
      | [ { "documents": [ { "identifier": "document1.txt", "content": "A Test." } ], "metadata": { "@context": { "ausnc": "http://ns.ausnc.org.au/schemas/ausnc_md_model/", "corpus": "http://ns.ausnc.org.au/corpora/", "dcterms": "http://purl.org/dc/terms/", "dcterms": "http://purl.org/dc/terms/", "foaf": "http://xmlns.com/foaf/0.1/", "hcsvlab": "http://hcsvlab.org/vocabulary/" }, "@graph": [ { "@id": "item1", "@type": "ausnc:AusNCObject", "ausnc:document": [ { "@id": "document1.txt", "@type": "foaf:Document", "dcterms:identifier": "document1.txt", "dcterms:title": "document1#Text", "dcterms:type": "Text" } ], "dcterms:identifier": "item1", "hcsvlab:display_document": { "@id": "document1.txt" }, "hcsvlab:indexable_document": { "@id": "document1.txt" } } ] } } ] |
    And I reindex the collection "test"
    And I am logged in as "researcher@alveo.edu.au"
    When I go to the delete document web path for "document1.txt" in "test:item1"
    Then I should get a security error "You are not authorised to access this page"

  @create_collection
  Scenario: Verify confirmation popup appears when deleting a document
    Given I ingest a new collection "test" through the api with the API token for "data_owner@alveo.edu.au"
    And I make a JSON post request for the collection page for id "test" with the API token for "data_owner@alveo.edu.au" with JSON params
      | items |
      | [ { "documents": [ { "identifier": "document1.txt", "content": "A Test." } ], "metadata": { "@context": { "ausnc": "http://ns.ausnc.org.au/schemas/ausnc_md_model/", "corpus": "http://ns.ausnc.org.au/corpora/", "dcterms": "http://purl.org/dc/terms/", "dcterms": "http://purl.org/dc/terms/", "foaf": "http://xmlns.com/foaf/0.1/", "hcsvlab": "http://hcsvlab.org/vocabulary/" }, "@graph": [ { "@id": "item1", "@type": "ausnc:AusNCObject", "ausnc:document": [ { "@id": "document1.txt", "@type": "foaf:Document", "dcterms:identifier": "document1.txt", "dcterms:title": "document1#Text", "dcterms:type": "Text" } ], "dcterms:identifier": "item1", "hcsvlab:display_document": { "@id": "document1.txt" }, "hcsvlab:indexable_document": { "@id": "document1.txt" } } ] } } ] |
    And I reindex the collection "test"
    And I am logged in as "data_owner@alveo.edu.au"
    And I am on the catalog page for "test:item1"
    When I click the delete icon for document "document1.txt" of item "test:item1"
    Then The popup text should contain "Are you sure you want to delete this document?"

  @create_collection
  Scenario: Delete a document as the item owner (API ingested collection)
    Given I make a JSON post request for the collections page with the API token for "data_owner@alveo.edu.au" with JSON params
      | name | collection_metadata |
      | Test | {"@context": {"Test": "http://collection.test", "dc": "http://purl.org/dc/elements/1.1/", "dcmitype": "http://purl.org/dc/dcmitype/", "marcrel": "http://www.loc.gov/loc.terms/relators/", "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdfs": "http://www.w3.org/2000/01/rdf-schema#", "xsd": "http://www.w3.org/2001/XMLSchema#" }, "@id": "http://collection.test", "@type": "dcmitype:Collection", "dc:creator": "Pam Peters", "dc:rights": "All rights reserved to Data Owner", "dc:subject": "English Language", "dc:title": "A test collection", "marcrel:OWN": "Data Owner"} |
    And I make a JSON post request for the collection page for id "test" with the API token for "data_owner@alveo.edu.au" with JSON params
      | items |
      | [ { "documents": [ { "identifier": "document1.txt", "content": "This document had its content provided as part of the JSON request." } ], "metadata": { "@context": { "ausnc": "http://ns.ausnc.org.au/schemas/ausnc_md_model/", "corpus": "http://ns.ausnc.org.au/corpora/", "dcterms": "http://purl.org/dc/terms/", "dcterms": "http://purl.org/dc/terms/", "foaf": "http://xmlns.com/foaf/0.1/", "hcsvlab": "http://hcsvlab.org/vocabulary/", "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdfs": "http://www.w3.org/2000/01/rdf-schema#", "xsd": "http://www.w3.org/2001/XMLSchema#" }, "@graph": [ { "@id": "item1", "@type": "ausnc:AusNCObject", "ausnc:document": [ { "@id": "document1.txt", "@type": "foaf:Document", "dcterms:identifier": "document1.txt", "dcterms:title": "document1#Text", "dcterms:type": "Text" } ], "dcterms:identifier": "item1", "hcsvlab:display_document": { "@id": "document1.txt" }, "hcsvlab:indexable_document": { "@id": "document1.txt" } } ] } } ] |
    And I reindex the collection "test"
    And I am logged in as "data_owner@alveo.edu.au"
    When I go to the delete document web path for "document1.txt" in "test:item1"
    Then I should be on the catalog page for "test:item1"
    And the document "document1.txt" under item "item1" in collection "test" should not exist in the database
    And the file "document1.txt" should not exist in the directory for the collection "test"
    And Sesame should not contain a document with file_name "document1.txt" in collection "test"
    And I should not see link "Closebox" to "/catalog/test/item1/document/document1.txt/delete"
    And I should not see "document1.txt Text "

  @create_collection
  Scenario: Delete a document as the item owner (manual ingested collection)
    Given I ingest a new collection "test" through the api with the API token for "data_owner@alveo.edu.au"
    And I make a JSON post request for the collection page for id "test" with the API token for "data_owner@alveo.edu.au" with JSON params
      | items |
      | [ { "documents": [ { "identifier": "document1.txt", "content": "A Test." } ], "metadata": { "@context": { "ausnc": "http://ns.ausnc.org.au/schemas/ausnc_md_model/", "corpus": "http://ns.ausnc.org.au/corpora/", "dcterms": "http://purl.org/dc/terms/", "dcterms": "http://purl.org/dc/terms/", "foaf": "http://xmlns.com/foaf/0.1/", "hcsvlab": "http://hcsvlab.org/vocabulary/" }, "@graph": [ { "@id": "item1", "@type": "ausnc:AusNCObject", "ausnc:document": [ { "@id": "document1.txt", "@type": "foaf:Document", "dcterms:identifier": "document1.txt", "dcterms:title": "document1#Text", "dcterms:type": "Text" } ], "dcterms:identifier": "item1", "hcsvlab:display_document": { "@id": "document1.txt" }, "hcsvlab:indexable_document": { "@id": "document1.txt" } } ] } } ] |
    And I reindex the collection "test"
    And I am logged in as "data_owner@alveo.edu.au"
    When I go to the delete document web path for "document1.txt" in "test:item1"
    Then I should be on the catalog page for "test:item1"
    And the document "document1.txt" under item "item1" in collection "test" should not exist in the database
    And the file "document1.txt" should not exist in the directory for the collection "test"
    And Sesame should not contain a document with file_name "document1.txt" in collection "test"
    And I should not see link "Closebox" to "/catalog/test/item1/document/document1.txt/delete"
    And I should not see "document1.txt Text "
