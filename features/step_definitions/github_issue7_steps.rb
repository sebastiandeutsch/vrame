When /^I sign\-in$/ do
  # debugger
  
  fill_in('user_session_email',    :with => 'vrame@example.com')
  fill_in('user_session_password', :with => 'vrame')
  
  click_button('user_session_submit')
  selenium.wait_for_page_to_load
end

When /^I add the category "([^\"]*)"$/ do |title|
  click_link 'new-category'
  selenium.wait_for_page_to_load
  
  fill_in('category_title', :with => title)
  click_button 'category_submit'
  selenium.wait_for_page_to_load
end

When /^I select the category "([^\"]*)"$/ do |friendly_id|
  click_link "select-category-#{friendly_id}"
  selenium.wait_for_condition('selenium.browserbot.getCurrentWindow().jQuery.active == 0', 5000)
end

When /^I delete the category "([^\"]*)"$/ do |friendly_id|
  click_link "delete-category-#{friendly_id}"
  selenium.wait_for_page_to_load
end