@desktop
@downloads
@download_test
@product_download
@nightly

Feature: Product Download Page - An authorised customer can download EAP via download manager when acepting Red Hat T&C's.

  As a develpers.redhat.com site visitor,
  I want to be able to register and download the Red Hat products.

  @logout
  Scenario: Newly registered site visitor navigates to product Download page and clicks on download, accepts Redhat T&C's should initiate download.
    Given I register a new account
    And I am on the Product Download page for eap
    When I click to download the featured download of "Enterprise Application Platform"
    Then I should see the eap get started page with a confirmation message "Thank you for downloading Enterprise Application Platform"

  @logout
  Scenario: Unauthorized customer must log in in order to Download EAP
    Given I am a registered site visitor
    And I am on the Product Download page for eap
    When I click to download the featured download of "Enterprise Application Platform"
    And I log in with a valid username
    Then I should see the eap get started page with a confirmation message "Thank you for downloading Enterprise Application Platform"
