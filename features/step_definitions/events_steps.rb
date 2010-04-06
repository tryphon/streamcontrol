Then /^I should see an event "([^\"]*)"$/ do |message|
  visit "/events"
  response.should contain(message)
end

Then /^I should not see an event "([^\"]*)"$/ do |message|
  visit "/events"
  response.should_not contain(message)
end
