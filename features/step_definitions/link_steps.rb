Then /^(?:|I )should see a "([^\"]*)" link$/ do |text|
  page.should have_xpath('//a', :text => text)
end
