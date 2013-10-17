@ingest_qa_collections
Feature: Searching for items
  As a Researcher,
  I want to search for items
  So that I can add them to my item lists
# Don't need to test Blacklight comprehensively
# Just test any extensions to Blacklight we have made

  Background:
    Given I have the usual roles and permissions
    Given I have users
      | email                       | first_name | last_name |
      | researcher@intersect.org.au | Researcher | One       |
      | data_owner@intersect.org.au | Researcher | One       |
    Given I have user "researcher@intersect.org.au" with the following groups
      | collectionName  | accessType  |
      | cooee           | read        |
      | austlit         | read        |
      | ice             | read        |
    And "researcher@intersect.org.au" has role "researcher"
    And "data_owner@intersect.org.au" has role "data_owner"
    And I am logged in as "researcher@intersect.org.au"
    And I am on the home page

  @javascript
  Scenario: Search returns correct results
    When I have done a search with collection "austlit"
    Then I should see "blacklight_results" table with
      | Identifier          | Type(s)             |
      | austlit:adaessa.xml | Original, Raw, Text |
      | austlit:bolroma.xml | Original, Raw, Text |

  Scenario: Must be logged in to see search history
    Given I follow "researcher@intersect.org.au"
    And I follow "Logout"
    And I am on the search history page
    Then I should see "Please enter your email and password to log in"

  @javascript
  Scenario: Search for simple term in all metadata
    When I expand the facet Search Metadata
    And I fill in "Metadata" with "monologue"
    And I press "search_metadata"
    Then I should see "blacklight_results" table with
      | Identifier          | Title                         | Created Date | Type(s)             |
      | ice:S2B-035 	    | The Money or the Gun 	        | 3/5/94 	   | Text                |

  @javascript
  Scenario: Search for two simple term in all metadata joined with AND
    When I expand the facet Search Metadata
    And I fill in "Metadata" with "University AND Romance"
    And I press "search_metadata"
    Then I should see "blacklight_results" table with
      | Identifier          | Title                         | Created Date | Type(s)             |
      | austlit:bolroma.xml | A Romance of Canvas Town 	    | 1898 	       | Original, Raw, Text |

  @javascript
  Scenario: Search for two simple term in all metadata joined with OR
    When I expand the facet Search Metadata
    And I fill in "Metadata" with "University OR Romance"
    And I press "search_metadata"
    Then I should see "blacklight_results" table with
      | Identifier          | Title                         | Created Date | Type(s)             |
      | austlit:adaessa.xml | Australian Essays 	        | 1886 	       | Original, Raw, Text |
      | austlit:bolroma.xml | A Romance of Canvas Town 	    | 1898 	       | Original, Raw, Text |

  @javascript
  Scenario: Search for term with tilde in all metadata
    When I expand the facet Search Metadata
    And I fill in "Metadata" with "Univarsoty~"
    And I press "search_metadata"
    Then I should see "blacklight_results" table with
      | Identifier          | Title                         | Created Date | Type(s)             |
      | austlit:adaessa.xml | Australian Essays             | 1886 	       | Original, Raw, Text |
      | austlit:bolroma.xml | A Romance of Canvas Town 	    | 1898 	       | Original, Raw, Text |

  @javascript
  Scenario: Search for term with asterisk in all metadata
    When I expand the facet Search Metadata
    And I fill in "Metadata" with "Correspon*"
    And I press "search_metadata"
    Then I should see a table with the following rows in any order:
      | Identifier          | Created Date | Type(s)             |
      | cooee:1-001         | 10/11/1791   | Original, Raw, Text |
      | cooee:1-002         | 10/11/1791   | Text                |

  @javascript
  Scenario: Search for term with asterisk in all metadata and simple term in full_text
    When I fill in "q" with "can"
    And I expand the facet Search Metadata
    And I fill in "Metadata" with "Correspon*"
    And I press "search_metadata"
    Then I should see "blacklight_results" table with
      | Identifier          | Created Date | Type(s)             |
      | cooee:1-001         | 10/11/1791   | Original, Raw, Text |

  @javascript
  Scenario: Search for term with field:value in all metadata
    When I expand the facet Search Metadata
    And I fill in "Metadata" with "AUSNC_discourse_type_tesim:letter"
    And I press "search_metadata"
    Then I should see a table with the following rows in any order:
      | Identifier          | Created Date | Type(s)             |
      | cooee:1-001         | 10/11/1791   | Original, Raw, Text |
      | cooee:1-002         | 10/11/1791   | Text                |

  @javascript
  Scenario: Search for term using quotes in all metadata
    When I expand the facet Search Metadata
    And I fill in "Metadata" with:
    """
    date_group_facet:"1880 - 1889"
    """
    And I press "search_metadata"
    Then I should see "blacklight_results" table with
      | Identifier          | Created Date | Type(s)             |
      | austlit:adaessa.xml | 1886         | Original, Raw, Text |

  @javascript
  Scenario: Search for term using ranges in all metadata
    When I expand the facet Search Metadata
    And I fill in "Metadata" with "[1810 TO 1899]"
    And I press "search_metadata"
    Then I should see "blacklight_results" table with
      | Identifier          | Title                         | Created Date | Type(s)             |
      | austlit:adaessa.xml | Australian Essays             | 1886         | Original, Raw, Text |
      | austlit:bolroma.xml | A Romance of Canvas Town      | 1898         | Original, Raw, Text |

  @javascript
  Scenario: The metadata search should not search the full text
    When I expand the facet Search Metadata
    And I fill in "Metadata" with:
    """
    "Francis Adams"
    """
    And I press "search_metadata"
    #And pause
    Then I should see "blacklight_results" table with
      | Identifier          | Title                         | Created Date | Type(s)             |
      | austlit:adaessa.xml | Australian Essays             | 1886         | Original, Raw, Text |
    Then I expand the facet Search Metadata
    And I fill in "Metadata" with ""
    And I fill in "q" with:
    """
    "Francis Adams"
    """
    And I press "search_metadata"
    Then I should see "blacklight_results" table with
      | Identifier          | Title                         | Created Date | Type(s)             |

