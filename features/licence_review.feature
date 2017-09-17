Feature: Managing Subscriptions to Collections
  As a Data Owner, I want Researchers to be able to agree to the licence terms
  which I have set for my Collections and Collection Lists.

  Background:
    Given I have the usual roles and permissions
    Given I have users
      | email                       | first_name | last_name |
      | data_owner@alveo.edu.au | dataOwner  | One       |
      | researcher@alveo.edu.au | Edmund     | Muir      |
    Given "data_owner@alveo.edu.au" has role "data owner"
    Given "researcher@alveo.edu.au" has role "researcher"
    Given I ingest "cooee:1-001"
    Given I ingest "auslit:adaessa"
    Given I ingest licences
    Given Collections ownership is
      | collection | owner_email                 |
      | cooee      | data_owner@alveo.edu.au |
      | austlit    | data_owner@alveo.edu.au |
    And User "data_owner@alveo.edu.au" has a Collection List called "List_1" containing
      | collection |
      | cooee      |

  @javascript
  Scenario: Verifying that my Collections and Collection Lists with no licence do not appear on the Licence Agreements page
    Given I am logged in as "data_owner@alveo.edu.au"
    And I am on the licence agreements page
    Then I should see "There are no licensed collections or collection lists visible in the system"

  @javascript
  Scenario: Verifying that my Collections and Collection Lists with a licence do appear on the Licence Agreements page
    And I am logged in as "data_owner@alveo.edu.au"
    And I have added a licence to Collection "austlit"
    And I have added a licence to Collection List "List_1"
    And I am on the licence agreements page
    Then the Review and Acceptance of Licence Terms table should have
      | title   | collection | owner                       | state | actions |
      | List_1  | 1          | data_owner@alveo.edu.au | Owner |         |
      | austlit | 1          | data_owner@alveo.edu.au | Owner |         |

  @javascript
  Scenario: Verifying that other users' Collections and Collection Lists with no licence do not appear on the Licence Agreements page
    Given I am logged in as "researcher@alveo.edu.au"
    And I am on the licence agreements page
    Then I should see "There are no licensed collections or collection lists visible in the system"

  @javascript
  Scenario: Verifying that other users; Collections and Collection Lists with a licence do appear on the Licence Agreements page
    And I am logged in as "data_owner@alveo.edu.au"
    And I have added a licence to Collection "austlit"
    And I have added a licence to Collection List "List_1"
    And I follow "data_owner@alveo.edu.au"
    And I follow "Logout"
    And I am logged in as "researcher@alveo.edu.au"
    And I am on the licence agreements page
    Then the Review and Acceptance of Licence Terms table should have
      | title   | collection | owner                       | state        | actions                        |
      | List_1  | 1          | data_owner@alveo.edu.au | Not Accepted | Preview & Accept Licence Terms |
      | austlit | 1          | data_owner@alveo.edu.au | Not Accepted | Preview & Accept Licence Terms |

  @javascript
  Scenario: Verifying that other users; Private Collections and Private Collection Lists with a licence do appear on the Licence Agreements page
    And I am logged in as "data_owner@alveo.edu.au"
    And I have added a licence to private Collection "austlit"
    And I have added a licence to private Collection List "List_1"
    And I follow "data_owner@alveo.edu.au"
    And I follow "Logout"
    And I am logged in as "researcher@alveo.edu.au"
    And I am on the licence agreements page
    Then the Review and Acceptance of Licence Terms table should have
      | title   | collection | owner                       | state      |
      | List_1  | 1          | data_owner@alveo.edu.au | Unapproved |
      | austlit | 1          | data_owner@alveo.edu.au | Unapproved |

  @javascript
  Scenario: Requesting access to a private collection list
    And I am logged in as "data_owner@alveo.edu.au"
    And I have added a licence to private Collection List "List_1"
    And I follow "data_owner@alveo.edu.au"
    And I follow "Logout"
    And I am logged in as "researcher@alveo.edu.au"
    And I am on the licence agreements page
    And I follow "Request Access"
    And I follow element with id "request_access0"
    Then the Review and Acceptance of Licence Terms table should have
      | title  | collection | owner                       | state             |
      | List_1 | 1          | data_owner@alveo.edu.au | Awaiting Approval |

  @javascript
  Scenario: Requesting access to a private collection
    And I am logged in as "data_owner@alveo.edu.au"
    And I have added a licence to private Collection "austlit"
    And I follow "data_owner@alveo.edu.au"
    And I follow "Logout"
    And I am logged in as "researcher@alveo.edu.au"
    And I am on the licence agreements page
    And I follow "Request Access"
    And I follow element with id "request_access0"
    Then the Review and Acceptance of Licence Terms table should have
      | title   | collection | owner                       | state             |
      | austlit | 1          | data_owner@alveo.edu.au | Awaiting Approval |

  @javascript
  Scenario: Viewing an access request as a data owner
    And I am logged in as "data_owner@alveo.edu.au"
    And I have added a licence to private Collection "austlit"
    And I follow "data_owner@alveo.edu.au"
    And I follow "Logout"
    And I am logged in as "researcher@alveo.edu.au"
    And I am on the licence agreements page
    And I follow "Request Access"
    And I follow element with id "request_access0"
    And I follow "researcher@alveo.edu.au"
    And I follow "Logout"
    And I am logged in as "data_owner@alveo.edu.au"
    And I follow "data_owner@alveo.edu.au"
    And I follow "Admin"
    And I follow "Manage Access To Collections"
    Then I should be on the licence requests page
    And I should see "access_requests" table with
      | First name | Last name | Email                       | Collection/Collection List |
      | Edmund     | Muir      | researcher@alveo.edu.au | austlit                    |

  Scenario: Viewing an empty list of licence requests
    And I am logged in as "data_owner@alveo.edu.au"
    And I am on the licence requests page
    Then I should see "No requests to display"

  @javascript
  Scenario: Cancelling an access request to a collection
    And I am logged in as "data_owner@alveo.edu.au"
    And I have added a licence to private Collection "austlit"
    And I follow "data_owner@alveo.edu.au"
    And I follow "Logout"
    And I am logged in as "researcher@alveo.edu.au"
    And I am on the licence agreements page
    And I follow "Request Access"
    And I follow element with id "request_access0"
    And I follow "Cancel Request"
    And I follow element with id "request_cancel0"
    Then the Review and Acceptance of Licence Terms table should have
      | title   | collection | owner                       | state      |
      | austlit | 1          | data_owner@alveo.edu.au | Unapproved |

  @javascript
  Scenario: Email to alert data owner of licence request
    And I am logged in as "data_owner@alveo.edu.au"
    And I have added a licence to private Collection List "List_1"
    And I follow "data_owner@alveo.edu.au"
    And I follow "Logout"
    And I am logged in as "researcher@alveo.edu.au"
    And I am on the licence agreements page
    And I follow "Request Access"
    And I follow element with id "request_access0"
    And I follow "researcher@alveo.edu.au"
    And I follow "Logout"
    And I am logged in as "data_owner@alveo.edu.au"
    Then "data_owner@alveo.edu.au" should receive an email
    When I open the email
    Then I should see "An access request to a collection has been made with the following details" in the email body
    And I click the first link in the email
    Then I should be on the licence requests page


  @javascript
  Scenario: Approving a collection request
    And I am logged in as "data_owner@alveo.edu.au"
    And I have added a licence to private Collection "austlit"
    And there is a licence request for collection "austlit" by "researcher@alveo.edu.au"
    And I am on the licence requests page
    And I follow "Approve"
    Then "researcher@alveo.edu.au" should receive an email
    When I open the email
    Then I should see "You made a request for access to austlit. Your request has been approved." in the email body
    And I follow "data_owner@alveo.edu.au"
    And I follow "Logout"
    And I am logged in as "researcher@alveo.edu.au"
    And I am on the licence agreements page
    Then the Review and Acceptance of Licence Terms table should have
      | title   | collection | owner                       | state    |
      | austlit | 1          | data_owner@alveo.edu.au | Approved |

  @javascript
  Scenario: Approving a collection list request
    And I am logged in as "data_owner@alveo.edu.au"
    And I have added a licence to private Collection List "List_1"
    And there is a licence request for collection list "List_1" by "researcher@alveo.edu.au"
    And I am on the licence requests page
    And I follow "Approve"
    Then "researcher@alveo.edu.au" should receive an email
    When I open the email
    Then I should see "You made a request for access to List_1. Your request has been approved." in the email body
    And I follow "data_owner@alveo.edu.au"
    And I follow "Logout"
    And I am logged in as "researcher@alveo.edu.au"
    And I am on the licence agreements page
    Then the Review and Acceptance of Licence Terms table should have
      | title  | collection | owner                       | state    |
      | List_1 | 1          | data_owner@alveo.edu.au | Approved |

  @javascript
  Scenario: Rejecting a collection request
    And I am logged in as "data_owner@alveo.edu.au"
    And I have added a licence to private Collection "austlit"
    And there is a licence request for collection "austlit" by "researcher@alveo.edu.au"
    And I am on the licence requests page
    And I follow "Reject"
    And I fill in "reason" with "rejected for unknown user"
    And I follow element with id "reject_request0"
    Then "researcher@alveo.edu.au" should receive an email
    When I open the email
    Then I should see "You made a request for access to austlit. Your request has been rejected." in the email body
    And I should see "rejected for unknown user" in the email body
    And I follow "data_owner@alveo.edu.au"
    And I follow "Logout"
    And I am logged in as "researcher@alveo.edu.au"
    And I am on the licence agreements page
    Then the Review and Acceptance of Licence Terms table should have
      | title   | collection | owner                       | state      |
      | austlit | 1          | data_owner@alveo.edu.au | Unapproved |

  @javascript
  Scenario: Rejecting a collection list request
    And I am logged in as "data_owner@alveo.edu.au"
    And I have added a licence to private Collection List "List_1"
    And there is a licence request for collection list "List_1" by "researcher@alveo.edu.au"
    And I am on the licence requests page
    And I follow "Reject"
    And I fill in "reason" with "rejected for unknown user"
    And I follow element with id "reject_request0"
    Then "researcher@alveo.edu.au" should receive an email
    When I open the email
    Then I should see "You made a request for access to List_1. Your request has been rejected." in the email body
    And I should see "rejected for unknown user" in the email body
    And I follow "data_owner@alveo.edu.au"
    And I follow "Logout"
    And I am logged in as "researcher@alveo.edu.au"
    And I am on the licence agreements page
    Then the Review and Acceptance of Licence Terms table should have
      | title  | collection | owner                       | state      |
      | List_1 | 1          | data_owner@alveo.edu.au | Unapproved |

  @javascript
  Scenario: Accepting terms to private collection after successful request
    And I am logged in as "data_owner@alveo.edu.au"
    And I have added a licence to private Collection "austlit"
    And there is a licence request for collection "austlit" by "researcher@alveo.edu.au"
    And I am on the licence requests page
    And I follow "Approve"
    Then "researcher@alveo.edu.au" should receive an email
    When I open the email
    Then I should see "You made a request for access to austlit. Your request has been approved." in the email body
    And I follow "data_owner@alveo.edu.au"
    And I follow "Logout"
    And I am logged in as "researcher@alveo.edu.au"
    And I am on the licence agreements page
    And I follow "Preview & Accept Licence Terms"
    And I click "Accept" on the 1st licence dialogue
    Then I should see "Licence terms to collection austlit accepted"
    And the Review and Acceptance of Licence Terms table should have
      | title   | collection | owner                       | state    |
      | austlit | 1          | data_owner@alveo.edu.au | Accepted |

  @javascript
  Scenario: Verifying that one can click through to the details of a collection
    And I am logged in as "data_owner@alveo.edu.au"
    And I have added a licence to Collection "austlit"
    And I follow "data_owner@alveo.edu.au"
    And I follow "Logout"
    And I am logged in as "researcher@alveo.edu.au"
    And I am on the licence agreements page
    Then the Review and Acceptance of Licence Terms table should have
      | title   | collection | owner                       | state        | actions                        |
      | austlit | 1          | data_owner@alveo.edu.au | Not Accepted | Preview & Accept Licence Terms |
    When I click the link in the 1st column of the 1st row of the "collections" table
    Then I should see "AustLit provides full-text access to hundreds of examples of out of copyright poetry, fiction and criticism ranging from 1795 to the 1930s"
    And I should see "Back to Licence Agreements"
    And I should see "Collection Details"
    When I click "Back to Licence Agreements"
    Then the Review and Acceptance of Licence Terms table should have
      | title   | collection | owner                       | state        | actions                        |
      | austlit | 1          | data_owner@alveo.edu.au | Not Accepted | Preview & Accept Licence Terms |

  @javascript
  Scenario: Verifying that one can show which collections are in a collection list and then click through to their details
    And I am logged in as "data_owner@alveo.edu.au"
    And I have added a licence to Collection List "List_1"
    And I follow "data_owner@alveo.edu.au"
    And I follow "Logout"
    And I am logged in as "researcher@alveo.edu.au"
    And I am on the licence agreements page
    Then the Review and Acceptance of Licence Terms table should have
      | title  | collection | owner                       | state        | actions                        |
      | List_1 | 1          | data_owner@alveo.edu.au | Not Accepted | Preview & Accept Licence Terms |
    When I click the button in the 1st column of the 1st row of the "collections" table
    And I wait for 2 seconds
    And I click "cooee"
    And I wait for 2 seconds
    Then I should see "Corpus of Oz Early English"
    And I should see "Back to Licence Agreements"
    And I should see "Collection Details"
    When I click "Back to Licence Agreements"
    Then the Review and Acceptance of Licence Terms table should have
      | title  | collection | owner                       | state        | actions                        |
      | List_1 | 1          | data_owner@alveo.edu.au | Not Accepted | Preview & Accept Licence Terms |

  @javascript
  Scenario: Verifying that I can sign up to licence agreements
    And I am logged in as "data_owner@alveo.edu.au"
    And I have added a licence to Collection "austlit"
    And I have added a licence to Collection List "List_1"
    And I follow "data_owner@alveo.edu.au"
    And I follow "Logout"
    And I am logged in as "researcher@alveo.edu.au"
    And I am on the licence agreements page
    Then the Review and Acceptance of Licence Terms table should have
      | title   | collection | owner                       | state        | actions                        |
      | List_1  | 1          | data_owner@alveo.edu.au | Not Accepted | Preview & Accept Licence Terms |
      | austlit | 1          | data_owner@alveo.edu.au | Not Accepted | Preview & Accept Licence Terms |
    When I click the button in the 5th column of the 1st row of the "collections" table
    And I wait for 2 seconds
#    And Save a screenshot with name "log/gg.png"
#    And Show Browser Inspector
    And I click "Close" on the 1st licence dialogue
#    And I wait for 2 seconds
#    And Save a screenshot with name "log/gg2.png"
    Then the Review and Acceptance of Licence Terms table should have
      | title   | collection | owner                       | state        | actions                        |
      | List_1  | 1          | data_owner@alveo.edu.au | Not Accepted | Preview & Accept Licence Terms |
      | austlit | 1          | data_owner@alveo.edu.au | Not Accepted | Preview & Accept Licence Terms |
    When I click the button in the 5th column of the 2nd row of the "collections" table
    And I wait for 2 seconds
    And I click "Accept" on the 2nd licence dialogue
    Then the Review and Acceptance of Licence Terms table should have
      | title   | collection | owner                       | state        | actions                        |
      | List_1  | 1          | data_owner@alveo.edu.au | Not Accepted | Preview & Accept Licence Terms |
      | austlit | 1          | data_owner@alveo.edu.au | Accepted     | Review Licence Terms           |

  @javascript
  Scenario: Users should be able to access a newly added collection in a collection list if they have already agreed to the licence of the collection list
    Given I have added a licence to Collection List "List_1"
    And I am logged in as "researcher@alveo.edu.au"
    And I am on the licence agreements page
    And I follow "Preview & Accept Licence Terms"
    And I click "Accept" on the 1st licence dialogue
    And I am on the home page
    Then I should see only the following collections displayed in the facet menu
      | collection |
      | cooee      |
    Then I am logged out
    And I am logged in as "data_owner@alveo.edu.au"
    And I am on the licences page
    And I check "allnonecheckbox"
    And I follow "Add selected to Collection list"
    And I click "List_1" in the add to collection list dropdown
    And I wait for 2 seconds
    Then I should see "1 added to Collection list List_1"
    Then I am logged out
    And I am on the home page
    And I am logged in as "researcher@alveo.edu.au"
    Then I should see only the following collections displayed in the facet menu
      | collection |
      | cooee      |
      | austlit    |

