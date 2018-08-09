Feature: Remove filter criteria
	In order to be able to remove a filter
	As a user
	I want to select a filter and remove it from my count

@javascript
Scenario: Remove filter
	Given I am in the count edit page
    And The count's datasource has fields with categories
   	And the count have fields already in use
  When I click the remove button
  Then the field get removed from the count
	