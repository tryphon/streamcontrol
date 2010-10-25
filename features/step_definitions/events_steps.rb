Then /^I should see an event "([^\"]*)"$/ do |message|
  visit "/events"
  page.should have_content(message)
end

Then /^I should see events:$/ do |table|
  visit "/events"
  table.raw.each do |message|
    message = message.first
    page.should have_content(message)
  end
end

Then /^I should not see an event "([^\"]*)"$/ do |message|
  visit "/events"
  page.should_not have_content(message)
end
