Feature: JBoss redirect to RHD

  Scenario Outline: Being redirected from a JBoss Developers page should show an alert message saying as such
    Given I am on a JBOSS referred page as "<url>"
    Then I should see a "Referrer" alert

    Examples: referred pages with an alert
      | url                       |
      | products                  |
      | products/fuse/overview    |
      | downloads                 |
      | topics/devops             |
      | community/contributor     |
      | events                    |
      | articles/frequently-asked-questions-no-cost-red-hat-enterprise-linux-developer-subscription |
