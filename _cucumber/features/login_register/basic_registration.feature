Feature: Basic personal registration

  As a visitor on the developers.redhat.com website,
  I want to register,
  So that I can use its services.

  @site_user
  @javascript
  Scenario: Customer registers
    Given I am on the Registration page
    When I complete the registration form
    Then I should receive an email containing an account verification link

  @site_user
  @logout
  @javascript
  Scenario: Customer verifies their account
    Given I am on the Registration page
    And I complete the registration form
    When I navigate to the verify account URL
    Then I should be logged in

  @site_user
  @javascript
  Scenario: Password validation
    Given I am on the Registration page
    When I try to enter passwords that do not match
    Then I should see a warning that "Passwords don't match"
