Feature: Crashing when loading deprecated cookies
  When I delete an active category
  as an administrator
  vrame should not crash

    Scenario: The homepage
      Given I am on vrame home
      When I sign-in
	  And I follow "Neue Kategorie"
	  And I add the category "Navigation"
	  And I select the category "navigation"
	  And I delete the category "navigation"
      Then I should see "Die Kategorie wurde gelöscht"