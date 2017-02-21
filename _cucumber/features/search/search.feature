@smoke
@stubbed
Feature: Search Page

  As a site visitor,
  I want to have the option to search for developer related content.
  So that I can find specific information.

  Scenario: Search field is hidden within the site header on search page.
    Given I am on the Home page
    When I search for "Containers"
    Then the search results page is displayed
    And the search field should not be displayed within the site header

  Scenario: Default results sort should be by "Relevance"
    Given I am on the Home page
    When I search for "Containers"
    Then the search results page is displayed
    And the default results sort should be by "Relevance"

  Scenario: Result sorting options should be: Relevance, Most Recent, and Title.
    Given I am on the Home page
    When I search for "Containers"
    Then the search results page is displayed
    And the result sorting options should be:
      | Relevance   |
      | Most Recent |

  Scenario: Default results per page should be 10
    Given I am on the Home page
    When I search for "Containers"
    Then the search results page is displayed
    And the default results count should be "10"

  Scenario: Result per page options should be: 10, 25, 50 and 100.
    Given I am on the Home page
    When I search for "Containers"
    Then the search results page is displayed
    And the result per page options should be:
      | 10  |
      | 25  |
      | 50  |
      | 100 |

  Scenario: Results sorting
    Given I am on the Home page
    When I search for "Containers"
    Then the search results page is displayed
    And I should see text "Showing "1-10" of results

  Scenario: Typing multiple words such as "eap 7 download" in the search box from the search header should retain the spaces.
    Given I am on the Home page
    When I search for "eap 7 download"
    Then the search box should contain "eap 7 download"

  Scenario: I search for something should return *no* entries, such as "bfehwfbhbn"
    Given I am on the Home page
    When I search for "bfehwfbhbn"
    Then the search results page is displayed
    And I should see a message "No results found"
    And below a I should see a message "Please try different keywords"
    And there will be no results displayed

  Scenario: Entering a search term and clicking the Search button in the Nav bar should trigger search.
    Given I am on the Home page
    When I enter "Containers" into the Site nav search box
    And I click on the search button
    Then the search results page is displayed
    And I should see "10" results containing "Container"

  Scenario: I search for something that returns ten (or more) pages of results should display pagination with ellipsis
    Given I am on the Home page
    When I search for "developer"
    Then the search results page is displayed
    Then I should see pagination with "5" pages with ellipsis
    And the following links should be available:
      | Next |
      | Last |
    And the following links should be unavailable:
      | First    |
      | Previous |

  Scenario: When I search for something displaying more than one page of results - clicking on the ‘Next’ link takes me to the next set of results.
    Given I have previously searched for "code"
    When I click on the pagination "Next" link
    Then I should see page "2" of the results
    And the following links should be available:
      | First    |
      | Previous |
      | Next     |
      | Last     |

  @desktop
  Scenario: When I previously clicked on the 'Next' link - clicking on the ‘Previous’ link takes back to the previous set of results.
    Given I have previously searched for "code"
    And I am on page "2" of the results
    When I click on the pagination "Previous" link
    Then I should see page "1" of the results
    And the following links should be available:
      | Next |
      | Last |
    And the following links should be unavailable:
      | First    |
      | Previous |

  @stubbed_only
  Scenario: I search for something that returns five pages of results should not display pagination with ellipsis
    Given I have previously searched for "foobar"
    Then I should see pagination with "5" pages without ellipsis
    And the following links should be available:
      | Next |
      | Last |
    And the following links should be unavailable:
      | First    |
      | Previous |

  Scenario: I search for something that returns one page of results only should display no pagination
    Given I have previously searched for "foobar"
    Then I should not see pagination with page numbers

  @desktop
  Scenario: When I previously clicked on the 'Next' link - clicking on the ‘Previous’ link takes back to the previous set of results.
    Given I have previously searched for "code"
    And I am on page "2" of the results
    When I click on the pagination "Previous" link
    Then I should see page "1" of the results
    And the following links should be available:
      | Next |
      | Last |
    And the following links should be unavailable:
      | First    |
      | Previous |

  Scenario: I search for something that returns two pages of results only should display pagination with two pages
    Given I have previously searched for "foobar"
    Then I should see pagination with "2" pages
    And the following links should be available:
      | Next |
      | Last |
    And the following links should be unavailable:
      | First    |
      | Previous |

  Scenario Outline: Blog posts are searchable
    Given I am on the Home page
    When I search for "<search_term>"
    And the search results page is displayed
    Then the results should contain "<search_term>"

    Examples: blog posts
      | search_term                         |
      | Red Hat JBoss Data Grid 7.0 is out  |
      | Knowledge Driven Microservices      |
      | Gems: A Few Helpful dotnet commands |

  Scenario Outline: StackOverflow posts are searchable
    Given I am on the Home page
    When I search for "<search_term>"
    And the search results page is displayed
    Then the results should contain "<search_term>"

    Examples: stackoverflow posts
      | search_term                                     |
      | Liferay 6.2 JBoss bundle is not getting started |
      | Installing NodeJS on RHEL(4)?                   |
      | New JDBC Driver for JBoss 6 EAP                 |

  Scenario Outline: KCS Documents are searchable
    Given I am on the Home page
    When I search for "<search_term>"
    And the search results page is displayed
    Then the results should contain "<search_term>"

    Examples: KCS Documents
      | search_term                                              |
      | How to disable Advisory topics and messages in A-MQ?     |
      | External topic subscriber to fabric can't create session |
      | How to configure wildcards in Virtual topic ?            |

  Scenario: Books are searchable
    Given I am on the Home page
    When I search for "Transitioning to .NET Core on Red Hat Enterprise Linux"
    And the search results page is displayed
    Then the results should contain "Transitioning to .NET Core on Red Hat Enterprise Linux"

  Scenario: Events are searchable
    Given I am on the Home page
    When I search for "DevNation"
    And the search results page is displayed
    Then the results should contain "DevNation"

  Scenario Outline: DEVELOPER-3077 - Topics should be listed first in results
    Given I am on the Home page
    When I search for "<topic>"
    And the search results page is displayed
    Then the related topic page for "<url>" should be the first result

    Examples: of Red hat Topics
      | topic                   | url                     |
      | Containers              | containers              |
      | Mobile                  | mobile                  |
      | DevOps                  | devops                  |
      | Web and API Development | web-and-api-development |
      | Enterprise Java         | enterprise-java         |
      | .NET                    | dotnet                  |
      | Internet of Things      | iot                     |

  Scenario: DEVELOPER-3078 - User searches on /search for 'red hat developers', the first result should be for https://developers.redhat.com/about.
    Given I am on the Home page
    When I search for "red hat developers"
    And the search results page is displayed
    Then first result should contain "https://developers.redhat.com/about"

  Scenario: DEVELOPER-3079 - Searching for 'enterprise linux' should return 'RHEL' product pages first
    Given I am on the Home page
    When I search for "enterprise linux"
    And the search results page is displayed
    Then the "RHEL" product overview page should be the first result

  Scenario: DEVELOPER-3557 - Site Search: Page does not scroll back to top
    Given I am on the Home page
    When I search for "Code"
    And the search results page is displayed
    When I click on the pagination "Next" link
    Then I should be scrolled to the top of the page

#  @manual
#  Scenario: Clicking on the X button on the search page should remove search string
#    Given I have previously searched for "code"
#    And the search box is empty
#    When I click on clear search button
#    Then the search box is empty

#  @manual
#  Scenario: Search page should be bookmarkable
#    Given I am on the Search page
#    And I search for "Containers"
#    When I bookmark the page
#    Then the bookmark should be added to my bookmarks
#    And the search criteria is added to the URL

#  @manual
#  Scenario: Revisiting a previously bookmarked search should redisplay the search page including the search query.
#    Given I visit a previous search from a bookmark
#    Then the Search page should be displayed
#    And the search query is replayed.
