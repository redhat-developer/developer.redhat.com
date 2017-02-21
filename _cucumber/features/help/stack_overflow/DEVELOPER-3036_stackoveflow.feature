@stubbed
Feature: Stack Overflow DEVELOPER-3036

  Scenario: SO page should have a 'Filter by Product' section
    Given I am on the Stack Overflow page
    Then I should see a Filter by product drop down menu with the following:
      | Show all                                      |
      | Red Hat JBoss Enterprise Application Platform |
      | Red Hat JBoss Web Server                      |
      | Red Hat Enterprise Linux                      |
      | Red Hat Software Collections                  |
      | Red Hat JBoss Fuse                            |
      | Red Hat OpenShift Container Platform          |
      | OpenJDK                                       |
      | Red Hat Developer Toolset                     |
      | Red Hat Developer Container Kit               |
      | Red Hat JBoss Developer Studio                |

  Scenario: When a user selects a product from the products filter the results are updated containing questions relating to that product.
    Given I am on the Stack Overflow page
    When I select "Red Hat Enterprise Linux" from the products filter
    Then the results should be updated containing questions relating to "Red Hat Enterprise Linux"

  Scenario: User should have to option to clear the search filter
    Given I am on the Stack Overflow page
    Then the default item within the Filter by product drop down menu should be "Show all"

  Scenario: User clears search filter
    Given I am on the Stack Overflow page
    When I have previously filtered results by "Red Hat JBoss Fuse"
    And I select "Show all" from the products filter
    Then the results should be updated containing questions relating to "All products"
