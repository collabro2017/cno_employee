Feature: Run a simple breakdown
	In order to run a simple breakdown
	As a user
	I want to click a button and get the results from a breakdown

@javascript
Scenario: Run breakdown button
	Given I am in the count edit page
		And the count have fields flagged as breakdown
	When I click the breakdown tab
	Then I can see a run breakdown button
		And I can see a message saying "Click here to run a breakdown"

@javascript
Scenario: Click breakdown button with fields already selected
	Given I am in the count edit page
		And the count have fields flagged as breakdown
		And I click the breakdown tab
		And there are breakdown fields selected
	When I click the breakdown button
	Then I can see the results broken down by the fields

@javascript
Scenario: Click the breakdown button with no fields selected
	Given I am in the count edit page
		And the count have fields flagged as breakdown
		And I click the breakdown tab
		And there are no breakdown fields selected
	When I click the breakdown button
	Then I can see a message saying "Please select at least one field before running the breakdown"