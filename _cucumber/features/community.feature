@smoke
Feature: Community Page Smoke Test
  In order to see other projects in the Red Hat community
  As generic site visitor
  I want to be able to see a list of community projects.

  Scenario: Community links
    Given I am on the Community page
    Then I should see the Community page title
    And I should see at least "3" promoted links
    And I should see at least "70" community links
