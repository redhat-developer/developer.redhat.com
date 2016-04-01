Given(/^I am on the Product Download page for ([^"]*)$/) do |product_id|
  @page.download_overview.open(product_id)
end

Then(/^I should see the ([^"]*) download overview page$/) do |product_id|
  # Temporary hack until selenium issue: Permission denied to access property "__raven__" (Selenium::WebDriver::Error::UnknownError) is removed.
  begin
    expect(page.current_url).to include "/products/#{product_id}/download/"
    @page.download_overview.send("wait_until_#{product_id}_download_page_visible")
  rescue
    expect(page.current_url).to include "/products/#{product_id}/download/"
    @page.download_overview.send("wait_until_#{product_id}_download_page_visible")
  end
end

When(/^I click to download the featured download of "([^"]*)"$/) do |product|
  version, url = get_featured_download_for(get_product_id(product))
  @page.download_overview.click_featured_download_for(product, version, url)
end

Then(/^the download (should|should not) initiate$/) do |negate|
  if negate.eql?('should')
    raise("Download was not initiated! There were #{Dir.glob("#{$download_dir}/*").count} files found in the download directory") unless downloading? == true
  else
    files = Dir["#{$download_dir}/*"].size
    expect(files).to be 0
  end
end

Then(/^I should see a list of products that are available to download$/) do
  expect(@page.downloads).to have_product_downloads :count => @available_downloads[0].size
  @page.downloads.available_downloads.should =~ @available_downloads[1]
end

Then(/^each available product download should contain a 'Download Latest' link$/) do
  expect(@page.downloads).to have_download_latest_links :count => @available_downloads[0].size
end

Then(/^the following 'Other developer resources' links should be displayed:$/) do |table|
  table.raw.each do |row|
    link = row.first
    expect(@page.downloads.other_resources_links).to include link.capitalize
  end
end

Then(/^I submit my company name and country$/) do
  @page.update_details.with(@site_user[:company_name], @site_user[:country])
end


Given(/^an authorized customer has previously downloaded eap$/) do
  step 'Given I register a new account'
  step 'And I am on the Product Download page for eap'
  step 'When I click to download the featured download of "Enterprise Application Server"'
  step 'And I accept the terms and conditions'
  step 'Then I should see the eap get started page with a confirmation message "Thank you for downloading Enterprise Application Server"'
end
