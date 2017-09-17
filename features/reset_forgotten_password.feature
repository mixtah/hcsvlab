Feature: Reset forgotten password
  In order to access the system
  As a user
  I want to be able to reset my password if I forgot it

  Background:
    Given a clear email queue

  Scenario: Reset forgotten password
    Given I have a user "georgina@alveo.edu.au"
    And I am on the home page
    When I follow "I forgot my password"
    And I fill in "Email" with "georgina@alveo.edu.au"
    And I press "Send me reset password instructions"
    Then I should see "If the email address you entered was the one previously used to sign up for an account, then you will receive an email with instructions about how to reset your password in a few minutes."
    And I should be on the login page
    And "georgina@alveo.edu.au" should receive an email
    When I open the email
    Then I should see "Someone has requested a link to change your password on the Alveo website. You can do this through the link below." in the email body
    When I click the first link in the email
    Then I should see "Change Your Password"
    When I fill in "Password" with "Pass.456"
    And I fill in "Password confirmation" with "Pass.456"
    And I press "Change Your Password"
    Then I should see "Your password was changed successfully. You are now signed in."
    And I should be able to log in with "georgina@alveo.edu.au" and "Pass.456"

  Scenario: Reset forgotten password for not registered user.
    Given I am on the home page
    When I follow "I forgot my password"
    And I fill in "Email" with "notuser@alveo.edu.au"
    And I press "Send me reset password instructions"
    Then I should see "If the email address you entered was the one previously used to sign up for an account, then you will receive an email with instructions about how to reset your password in a few minutes."
    And I should be on the login page
    And "notuser@alveo.edu.au" should receive an email
    When I open the email
    Then I should see "Alveo - Reset Password Request" in the email subject
    Then I should see "Someone has requested a link to change your password on the Alveo website (http://localhost:3000/). Unfortunately the email address entered, notuser@alveo.edu.au, is not registered with the system. Please enter the email address originally used to sign up for an account. You can do this through the link below." in the email body

  Scenario: Deactivated user gets an email saying they can't reset their password
    Given I have a deactivated user "deac@alveo.edu.au"
    When I request a reset for "deac@alveo.edu.au"
    Then I should see "If the email address you entered was the one previously used to sign up for an account, then you will receive an email with instructions about how to reset your password in a few minutes."
    And I should be on the login page
    And "deac@alveo.edu.au" should receive an email
    When I open the email
    Then I should see "Someone has requested a link to change your password on the Alveo site. However your account is not active so you cannot reset your password." in the email body

  Scenario: Pending approval user gets an email saying they can't reset their password
    Given I have a pending approval user "pa@alveo.edu.au"
    When I request a reset for "pa@alveo.edu.au"
    Then I should see "If the email address you entered was the one previously used to sign up for an account, then you will receive an email with instructions about how to reset your password in a few minutes."
    And I should be on the login page
    And "pa@alveo.edu.au" should receive an email
    When I open the email
    Then I should see "Someone has requested a link to change your password on the Alveo site. However your account is not active so you cannot reset your password." in the email body

  Scenario: Rejected as spam user trying to request a reset just sees default message but doesn't get email (so we don't reveal which users exist)
    Given I have a rejected as spam user "spam@alveo.edu.au"
    When I request a reset for "spam@alveo.edu.au"
    Then I should see "If the email address you entered was the one previously used to sign up for an account, then you will receive an email with instructions about how to reset your password in a few minutes."
    And I should be on the login page
    But "spam@alveo.edu.au" should receive no emails

  Scenario: Error displayed if email left blank
    Given I am on the home page
    When I request a reset for ""
    Then I should see "Email can't be blank"
    And I should see "I forgot my password"

  Scenario: New password and confirmation must match
    Given I have a user "georgina@alveo.edu.au"
    When I request a reset for "georgina@alveo.edu.au"
    And "georgina@alveo.edu.au" should receive an email
    And I open the email
    When I click the first link in the email
    And I fill in "Password" with "Pass.456"
    And I fill in "Password confirmation" with "Pass.123"
    And I press "Change Your Password"
    Then I should see "Password doesn't match confirmation"

  Scenario: New password must meet minimum requirements
    Given I have a user "georgina@alveo.edu.au"
    When I request a reset for "georgina@alveo.edu.au"
    And "georgina@alveo.edu.au" should receive an email
    And I open the email
    When I click the first link in the email
    And I fill in "Password" with "Pass"
    And I fill in "Password confirmation" with "Pass"
    And I press "Change Your Password"
    Then I should see "Password must be between 6 and 20 characters long and contain at least one uppercase letter, one lowercase letter, one digit and one symbol"

  Scenario: Link in email should only work once
    Given I have a user "georgina@alveo.edu.au"
    When I request a reset for "georgina@alveo.edu.au"
    And "georgina@alveo.edu.au" should receive an email
    And I open the email
    When I click the first link in the email
    And I fill in "Password" with "Pass.456"
    And I fill in "Password confirmation" with "Pass.456"
    And I press "Change Your Password"
    Then I should see "Your password was changed successfully. You are now signed in."
    When I follow "Logout"
    And I open the email
    When I click the first link in the email
    And I fill in "Password" with "Pass.000"
    And I fill in "Password confirmation" with "Pass.000"
    And I press "Change Your Password"
    Then I should see "Reset password token is invalid"
    And I should be able to log in with "georgina@alveo.edu.au" and "Pass.456"

  Scenario: Can't go to get new password page without the token in the email
    Given I have a user "georgina@alveo.edu.au"
    When I go to the reset password page
    Then I should see "You canoot access this page without coming from a password reset email. If you do come from a password reset email, please make sure you used the full URL provided."
