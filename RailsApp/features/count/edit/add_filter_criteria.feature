Feature: Add Filter Criteria
  In order to be able to filter the data by certain criteria
  As a user
  I want to select the fields that I will use for defining the criteria

@javascript
Scenario: Select field
  Given I am in the count edit page
    And The count's datasource has fields with categories
  When I drag and drop a field name from the fields box to the count workspace
  Then a copy of the field name gets added to the count work-space
    And the query gets updated

@javascript
Scenario: Select a field that has alredy been added
  Given I am in the count edit page
    And The count's datasource has fields with categories
  When I drag and drop a field name from the fields box to the count workspace
  Then I can see a message saying "The field is already in use."
  