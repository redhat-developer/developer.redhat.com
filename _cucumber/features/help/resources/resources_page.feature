Feature: DEVELOPER-1934 - Resources update: Implementation

  Scenario: On first visit to the Resources page - all results should be displayed
    Given I am on the Resources page
    Then none of the product filters should be checked
    And I should see text "Showing "1-10" of results

  Scenario: Result per page options should be: 10, 25, 50 and 100.
    Given I am on the Resources page
    When results have loaded
    Then the result per page options should be:
      | 10  |
      | 25  |
      | 50  |
      | 100 |

  Scenario Outline: Result per page options should be: 10, 25, 50 and 100.
    Given I am on the Resources page
    And results have loaded
    When I select "<number>" from the results per page filter
    Then I should see "<number>" results ordered by Most Recent

    Examples: results per page
      | number |
      | 10     |
      | 25     |
      | 50     |
      | 100    |

  Scenario:  On first visit to the Resources page - most recent item should be at the top
    Given I am on the Resources page
    Then I should see "10" results ordered by Most Recent

  Scenario Outline: User can filter results by resource type, Blog, Book, Code Artifact, Video
    Given I am on the Resources page
    And results have loaded
    When I click to filter results by "<filter type>"
    Then the results should be filtered by <result>

    Examples: Filter types and results.
      | filter type   | result     |
      | Blog Posts    | blogpost   |
      | Book          | book       |
      | Code Artifact | demo       |
      | Get Started   | getstarted |
      | Knowledgebase | article    |
      | Video         | video      |

  Scenario: Clicking on the remove filter icon should replay results without filter.
    Given I am on the Resources page
    And results have loaded
    And I click to filter results by "Code Artifact"
    When I uncheck the "Code Artifact" filter
    Then the default set of results are displayed

  Scenario: It should not be possible to filter by more than one type, if a different filter type is selected the results should display the new type.
    Given I am on the Resources page
    When I click to filter results by "Book"
    And the results for "Book" are displayed
    When I click to filter results by "Video"
    Then the results for "Video" are displayed
    And the results displayed should not contain "Book"

#  @later
#  Scenario: Quoted keywords should filter by items containing the full search string.
#    Given I am on the Resources page
#    When I enter "RHEL" into the Keyword's box
#    Then the results displayed should contain "RHEL" or "Red Hat Linux"
#
#  @later
#  Scenario: Non quoted keywords should filter by items containing any of the search items delimited by space.
#    Given I am on the Resources page
#    When I enter "Java Container Development Kit" into the Keyword's box
#    Then the results displayed should contain "Java" or "Containers"
#
#  @later
#  Scenario: Results must contain a relevant tag that relates to the product.
#    Given I am on the Resources page
#    When I enter "eap" into the Keyword's box
#    Then some of the results should contain a "eap" tag

  Scenario: Filter by product should display results related to that product
    Given I am on the Resources page
    When select "Red Hat Container Development Kit" from the product filter
    Then the results should be updated
    And some of the results should contain a "Containers" tag

  Scenario: All videos should show a thumbnail.
    Given I am on the Resources page
    When I click to filter results by "Video"
    Then all of the results should contain a "video" thumbnail

#  @later
#  Scenario Outline: Selecting drop down menu options from Publish Date should filter results.
#    Given I am on the Resources page
#    When I change the Publish date drop down menu to "<option>"
#    Then the results should be from "<option>"
#
#    Examples: Publish Date drop down menu options
#      | option       |
#      | Past Day     |
#      | Past Week    |
#      | Past Month   |
#      | Past Quarter |
#      | Past Year    |

  Scenario: When there are no results an appropriate message should be displayed.
    Given I am on the Resources page
    When I enter "bfehwfbhbn" into the Keyword's box
    Then I should see a message "No results found"

#  @later
#  Scenario: When no results message has previously been displayed, and then I search for a valid resource, the results are displayed and the message is removed.
#    Given I am on the Resources page
#    And I enter "bfehwfbhbn" into the Keyword's box
#    Then I should see a message "No results found."
#    When I enter "containers" into the Keyword's box
#    Then I should not see a message "No results found."
#    And some of the results should contain a "Containers" tag

  Scenario: Result pagination on first visit
    Given I am on the Resources page
    And results have loaded
    Then I should see pagination with "5" pages with ellipsis
    And the following links should be available:
      | Next |
      | Last |
    And the following links should be unavailable:
      | First    |
      | Previous |

#  @later
#  Scenario: I filter results that return two pages of results: should display pagination with two pages
#    Given I am on the Resources page
#    When I enter "?" into the Keyword's box
#    Then I should see pagination with "2" pages
#    And the following links should be available:
#      | Next |
#      | Last |
#    But the following links should be unavailable:
#      | First    |
#      | Previous |
#
#  @later
#  Scenario: I filter results that returns eight pages of results: should not display pagination with ellipsis
#    Given I am on the Resources page
#    When I search for "?"
#    Then I should see pagination with "5" pages without ellipsis
#    And the following links should be available:
#      | Next |
#      | Last |
#    And the following links should be unavailable:
#      | First    |
#      | Previous |

  @desktop
  Scenario: Clicking on the ‘Next’ link takes me to the next set of results.
    Given I am on the Resources page
    And results have loaded
    Then I should see pagination with "5" pages with ellipsis
    When I click on the pagination "Next" link
    Then I should see page "2" of the results
    And the following links should be available:
      | First    |
      | Previous |
      | Next     |
      | Last     |

  @desktop
  Scenario: Clicking on the ‘Previous’ link takes me back to the previous set of results.
    Given I am on the Resources page
    And I am on page "2" of the results
    When I click on the pagination "Previous" link
    Then I should see page "1" of the results
    And the following links should be available:
      | Next |
      | Last |
    And the following links should be unavailable:
      | First    |
      | Previous |

  Scenario: When a user selects a product filter, the URL is updated to reflect the selection.
    Given I am on the Resources page
    And I click to filter results by "Video"
    And select "Red Hat Container Development Kit" from the product filter
    When results have loaded
    Then the URL should include the selected filters
 
  @manual
  Scenario: User navigates to a previously filtered /resources URL 
    Given I have previously filtered results by "Video" and "Red Hat Container Development Kit" 
    When I copy the URL
    And paste the URL into a new tab
    Then the results should be filtered by  "Video" and "Red Hat Container Development Kit"
