Feature: Logging In
  In order to use the system
  As a user
  I want to login

  Background:
    Given I have roles
      | name       |
      | admin      |
      | Researcher |
    And I have a user "georgina@alveo.edu.au"
    And "georgina@alveo.edu.au" has role "admin"

  Scenario: Visit home before login
    Given I am a guest (not signed in yet)
    When I visit the system website (/)
    Then I should see the collection page

  Scenario: Successful login
    Given I am on the login page
    When I fill in "Email" with "georgina@alveo.edu.au"
    And I fill in "Password" with "Pas$w0rd"
    And I press "Log in"
    Then I should see "Logged in successfully."
    And I should be on the home page

  Scenario: Home page shows login form if user not already logged in
    Given I am on the home page
    When I fill in "Email" with "georgina@alveo.edu.au"
    And I fill in "Password" with "Pas$w0rd"
    And I press "Log in"
    Then I should see "Logged in successfully."
    And I should be on the home page

  Scenario: Home page is the search page once logged in
    Given I am on the login page
    And I attempt to login with "georgina@alveo.edu.au" and "Pas$w0rd"
    Then I should see "Above and Beyond Speech, Language and Music"
    Then I should see "A Virtual Lab for Human Communication Science"
    When I am on the home page
    Then I should see "Above and Beyond Speech, Language and Music"
    Then I should see "A Virtual Lab for Human Communication Science"

  Scenario: Should be redirected to the login page when trying to access a secure page
    Given I am on the list users page
    Then I should see "You need to log in before continuing."
    And I should be on the login page

  Scenario: Should be redirected to requested page after logging in following a redirect from a secure page
    Given I am on the list users page
    When I fill in "Email" with "georgina@alveo.edu.au"
    And I fill in "Password" with "Pas$w0rd"
    And I press "Log in"
    Then I should see "Logged in successfully."
    And I should be on the list users page

  Scenario Outline: Failed logins due to missing/invalid details
    Given I am on the login page
    When I fill in "Email" with "<email>"
    And I fill in "Password" with "<password>"
    And I press "Log in"
    Then I should see "Invalid email or password."
    And I should be on the login page
  Examples:
    | email                     | password | explanation      |
    |                           |          | nothing          |
    |                           | Pas$w0rd | missing email    |
    | georgina@alveo.edu.au |          | missing password |
    | fred@alveo.edu.au     | Pas$w0rd | invalid email    |
    | georgina@alveo.edu.au | blah     | wrong password   |

  Scenario Outline: Logging in as a deactivated / pending approval / rejected as spam with correct password
    Given I have a deactivated user "deact@alveo.edu.au"
    And I have a rejected as spam user "spammer@alveo.edu.au"
    And I have a pending approval user "pending@alveo.edu.au"
    And I am on the login page
    When I fill in "Email" with "<email>"
    And I fill in "Password" with "<password>"
    And I press "Log in"
    Then I should see "Your request for an account has been received. You will receive an email once your request is approved."
  Examples:
    | email                    | password |
    | deact@alveo.edu.au   | Pas$w0rd |
    | spammer@alveo.edu.au | Pas$w0rd |
    | pending@alveo.edu.au | Pas$w0rd |

  Scenario Outline: Logging in as a deactivated / pending approval / rejected as spam / with incorrect password should not reveal if user exists
    Given I have a deactivated user "deact@alveo.edu.au"
    And I have a rejected as spam user "spammer@alveo.edu.au"
    And I have a pending approval user "pending@alveo.edu.au"
    And I am on the login page
    When I fill in "Email" with "<email>"
    And I fill in "Password" with "<password>"
    And I press "Log in"
    Then I should see "Invalid email or password."
    And I should not see "Your account is not active."
  Examples:
    | email                    | password |
    | deact@alveo.edu.au   | pa       |
    | spammer@alveo.edu.au | pa       |
    | pending@alveo.edu.au | pa       |

  Scenario: Going to sign up then back to login should take you back to the home page
    Given I am on the home page
    And I click "New User"
    And I click "Log in"
    And I fill in "Email" with "georgina@alveo.edu.au"
    And I fill in "Password" with "Pas$w0rd"
    And I press "Log in"
    Then I should see "Logged in successfully."
    And I should be on the home page