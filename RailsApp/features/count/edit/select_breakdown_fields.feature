Feature: Select Breakdown Fields
  In order to be able to select breakdown fields
  As a user
  I want to select the fields that are available to run a breakdown

@javascript 
Scenario: The field is flagged as is_breakdown
	Given I am in the count edit page
		And the count have fields flagged as breakdown
	When I click the breakdown tab
	Then I can see the fields available for a breakdown count

@javascript
Scenario: Drag n' Drop a field available for a breakdown count and there are less than 3 added
	Given I am in the count edit page
		And the count have fields flagged as breakdown
	When I click the breakdown tab
		And I drag a field and drop it into the breakdown pane
		And there are less than 3 fields already in
	Then a copy of the field appears in the breakdown pane

@javascript
Scenario: Drag n' Drop a field available for a breakdown count and there are 3 added already
	Given I am in the count edit page
		And the count have fields flagged as breakdown
	When I click the breakdown tab
		And I drag a field and drop it into the breakdown pane
		And there are exactly 3 fields already in
	Then nothing happens

@javascript
Scenario: Drag n' Drop a field available for a breakdown count that already is being used
Given I am in the count edit page
		And the count have fields flagged as breakdown
	When I click the breakdown tab
		And I drag a field and drop it into the breakdown pane
		And the field is already in
	Then nothing happens
