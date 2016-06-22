Feature: Site navigation menu

  @mobile @smoke
  Scenario: A customer has correct login credentials can log in on mobile/tablet devices.
    Given I am on the Home page
    When I tap on Menu menu item
    Then I should see a primary nav bar with the following tabs:
      | Login    |
      | Register |

  @mobile @accepted_terms @logout @ignore
  Scenario: A customer has correct login credentials can log in on mobile/tablet devices.
    Given I am on the Login page
    And I log in with a valid password
    When I tap on Menu menu item
    Then I should be logged in

  @desktop @smoke
  Scenario: Primary navigation menu is visible
    Given I am on the Home page
    Then I should see a primary nav bar with the following tabs:
      | Topics       |
      | Technologies |
      | Community    |
      | Help         |
      | Downloads    |

  @mobile @smoke
  Scenario: Primary navigation is hidden behind a menu when on mobile devices
    Given I am on the Home page
    When I tap on Menu menu item
    Then I should see a primary nav bar with the following tabs:
      | Topics       |
      | Technologies |
      | Community    |
      | Help         |
      | Downloads    |

  @desktop @smoke
  Scenario: Hovering over the TOPICS menu should display additional sub-menu with options
    Given I am on the Home page
    When I hover over the Topics menu item
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
    When I hover over the Topics menu item
    Then each Topics sub-menu item should contain a link to its retrospective page:
      | name                    | href                    |
      | Containers              | containers              |
      | Mobile                  | mobile                  |
      | DevOps                  | devops                  |
      | Web and API Development | web-and-api-development |
      | Enterprise Java         | enterprise-java         |
      | .NET                    | dotnet                  |
      | Internet of Things      | iot                     |

  @mobile @smoke
  Scenario: Tapping TOPICS from drop down menu on Mobile/Tablet should display additional topics
    Given I am on the Home page
    When I tap on Topics menu item
    Then I should see the following "Topics" mobile sub-menu items:
      | Containers              |
      | Mobile                  |
      | DevOps                  |
      | Web and API Development |
      | Enterprise Java         |
      | .NET                    |
      | Internet of Things      |

  @products @desktop @smoke
  Scenario: Hovering over the TECHNOLOGIES menu should display additional sub-menu with available products
    Given I am on the Home page
    When I hover over the Technologies menu item
    Then I should see the following "Technologies" desktop sub-menu items:
      | INFRASTRUCTURE |
      | CLOUD          |
      | MOBILE         |
      | ACCELERATED DEVELOPMENT AND MANAGEMENT |
      | INTEGRATION AND AUTOMATION             |
    And the sub-menu should include a list of available technologies

  @products @desktop
  Scenario: TECHNOLOGIES sub-menu headings should link to retrospective section of the technologies page
    Given I am on the Home page
    When I hover over the Technologies menu item
    Then each Technologies sub-menu heading should contain a link to its retrospective section of the technologies page:
      | INFRASTRUCTURE                         |
      | CLOUD                                  |
      | MOBILE                                 |
      | ACCELERATED DEVELOPMENT AND MANAGEMENT |
      | INTEGRATION AND AUTOMATION             |

  @products @desktop @smoke
  Scenario: TECHNOLOGIES sub-menu headings should link to retrospective section of the technologies page
    Given I am on the Home page
    When I hover over the Technologies menu item
    Then each available technology should link to their retrospective product overview page

  @mobile @smoke
  Scenario: Tapping TECHNOLOGIES from drop down menu on Mobile/Tablet should display additional technologies
    Given I am on the Home page
    When I tap on Technologies menu item
    Then I should see the following "Technologies" mobile sub-menu items:
      | INFRASTRUCTURE |
      | CLOUD          |
      | MOBILE         |
      | ACCELERATED DEVELOPMENT AND MANAGEMENT |
      | INTEGRATION AND AUTOMATION             |

  @desktop @smoke
  Scenario: Hovering over the COMMUNITIES menu should display additional sub-menu with options
    Given I am on the Home page
    When I hover over the Community menu item
    Then I should see the following Community sub-menu items and their description:
      | name                    | description                                                     |
      | Developers Blog         | Insights & news on Red Hat developer tools, platforms and more  |
      | Events                  | Find the latest conferences, meetups, and virtual seminars      |
      | Open Source Communities | Community Projects that Red Hat participates in                 |
      | Content Contributors    | Share your knowledge. Contribute content to Red Hat Developers. |

  @products @desktop @smoke
  Scenario: COMMUNITIES sub-menu items should link to retrospective pages
    Given I am on the Home page
    When I hover over the Community menu item
    Then each Communities sub-menu item should contain a link to its retrospective page:
      | name                    | href                      |
      | Developers Blog         | blog                      |
      | Events                  | events                    |
      | Open Source Communities | projects                  |
      | Content Contributors    | community/contributor/    |

  @mobile @smoke
  Scenario: Tapping COMMUNITY from drop down menu on Mobile/Tablet should display additional communities
    Given I am on the Home page
    When I tap on Community menu item
    Then I should see the following "Community" mobile sub-menu items:
      | Developers Blog         |
      | Events                  |
      | Open Source Communities |
      | Content Contributors    |

  @desktop @smoke
  Scenario: Hovering over the HELP menu should display additional sub-menu with options
    Given I am on the Home page
    When I hover over the Help menu item
    Then I should see the following Help sub-menu items and their description:
      | name                 | description                                                                                           |
      | Resources            | Important technical resources for you in all shapes and sizes: blogs, books, code, videos and more.   |
      | Forums               | We've extended our popular JBoss.org forums to cover our entire Red Hat portfolio for you.            |
      | Stack Overflow Q&A   | You already use Stack Overflow, so we'll help you use it to find your best answers.                   |

  @products @desktop @smoke
  Scenario: HELP sub-menu items should link to retrospective pages
    Given I am on the Home page
    When I hover over the Help menu item
    Then each Help sub-menu item should contain a link to its retrospective page:
      | name                | href                  |
      | Resources           | resources             |
      | Forums              | forums                |
      | Stack Overflow Q&A  | stack-overflow        |

  @mobile @smoke
  Scenario: Tapping HELP from drop down menu on Mobile/Tablet should display additional help
    Given I am on the Home page
    When I tap on Help menu item
    Then I should see the following "Help" mobile sub-menu items:
      | Resources           |
      | Forums              |
      | Stack Overflow Q&A  |
