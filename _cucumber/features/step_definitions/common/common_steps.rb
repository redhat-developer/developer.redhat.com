Then(/^(I|they) should see the ([^"]*) page title$/) do |negate, page_title|
  expect(@page.current_page.title.downcase).to include(page_title.downcase)
end

Then(/^I should see a (verification|confirmation) message: "(.*)"$/) do |negate, message|
  expect(@page.current_page.verification_message).to have_text(message)
end
