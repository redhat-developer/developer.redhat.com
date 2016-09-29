Feature: Site navigation menu

  @desktop @smoke
  Scenario: Primary navigation menu is visible
    Given I am on the Home page
    Then I should see a primary nav bar with the following tabs:
      | Topics       |
      | Technologies |
      | Community    |
      | Help         |
      | Downloads    |

  @desktop @smoke
  Scenario: Hovering over the TOPICS menu should display additional sub-menu with options
    Given I am on the Home page
    When I click on the Topics menu item
    Then I should see the following "Topics" desktop sub-menu items:
      | Containers              |
      | Mobile                  |
      | DevOps                  |
      | Web and API Development |
      | Enterprise Java         |
      | .NET                    |
      | Internet of Things      |

  @desktop @smoke
  Scenario: TOPICS sub-menu items should link to retrospective pages
    Given I am on the Home page
    When I click on the Topics menu item
    Then each Topics sub-menu item should contain a link to its retrospective page:
      | name                    | href                    |
      | Containers              | containers              |
      | Mobile                  | mobile                  |
      | DevOps                  | devops                  |
      | Web and API Development | web-and-api-development |
      | Enterprise Java         | enterprise-java         |
      | .NET                    | dotnet                  |
      | Internet of Things      | iot                     |

  @products @desktop @smoke
  Scenario: Hovering over the TECHNOLOGIES menu should display additional sub-menu with available products
    Given I am on the Home page
    When I click on the Technologies menu item
    Then I should see the following "Technologies" desktop sub-menu items:
      | INFRASTRUCTURE                         |
      | CLOUD                                  |
      | MOBILE                                 |
      | ACCELERATED DEVELOPMENT AND MANAGEMENT |
      | INTEGRATION AND AUTOMATION             |
      | DEVELOPER TOOLS                        |
      | RUNTIMES                               |
    And the sub-menu should include a list of available technologies

  @products @desktop
  Scenario: TECHNOLOGIES sub-menu headings should link to retrospective section of the technologies page
    Given I am on the Home page
    When I click on the Technologies menu item
    Then each Technologies sub-menu heading should contain a link to its retrospective section of the technologies page:
      | INFRASTRUCTURE                         |
      | CLOUD                                  |
      | MOBILE                                 |
      | ACCELERATED DEVELOPMENT AND MANAGEMENT |
      | INTEGRATION AND AUTOMATION             |
      | DEVELOPER TOOLS                        |
      | RUNTIMES                               |

  @products @desktop @smoke
  Scenario: TECHNOLOGIES sub-menu headings should link to retrospective section of the technologies page
    Given I am on the Home page
    When I click on the Technologies menu item
    Then each available technology should link to their retrospective product overview page

  @desktop @smoke
  Scenario: Hovering over the COMMUNITIES menu should display additional sub-menu with options
    Given I am on the Home page
    When  I click on the Community menu item
    Then I should see the following Community sub-menu items and their description:
      | name                    | description                                                     |
      | Developers Blog         | Insights & news on Red Hat developer tools, platforms and more  |
      | Events                  | Find the latest conferences, meetups, and virtual seminars      |
      | Open Source Communities | Community Projects that Red Hat participates in                 |
      | Content Contributors    | Share your knowledge. Contribute content to Red Hat Developers. |

  @products @desktop @smoke
  Scenario: COMMUNITIES sub-menu items should link to retrospective pages
    Given I am on the Home page
    When  I click on the Community menu item
    Then each Communities sub-menu item should contain a link to its retrospective page:
      | name                    | href                  |
      | Developers Blog         | blog                  |
      | Events                  | events                |
      | Open Source Communities | projects              |
      | Content Contributors    | community/contributor |

  @desktop @smoke
  Scenario: Hovering over the HELP menu should display additional sub-menu with options
    Given I am on the Home page
    When  I click on the Help menu item
    Then I should see the following Help sub-menu items and their description:
      | name               | description                                                                                         |
      | Resources          | Important technical resources for you in all shapes and sizes: blogs, books, code, videos and more. |
      | Forums             | We've extended our popular JBoss.org forums to cover our entire Red Hat portfolio for you.          |
      | Stack Overflow Q&A | You already use Stack Overflow, so we'll help you use it to find your best answers.                 |

  @products @desktop @smoke
  Scenario: HELP sub-menu items should link to retrospective pages
    Given I am on the Home page
    When I click on the Help menu item
    Then each Help sub-menu item should contain a link to its retrospective page:
      | name               | href           |
      | Resources          | resources      |
      | Forums             | forums         |
      | Stack Overflow Q&A | stack-overflow |
